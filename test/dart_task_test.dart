import 'package:dart_task/dart_task.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  late Directory tempDirectory;
  late JsonTaskRepository repository;
  late TaskManager manager;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('dart_task_test_');
    repository = JsonTaskRepository('${tempDirectory.path}/tasks.json');
    manager = TaskManager(repository);
  });

  tearDown(() async {
    await tempDirectory.delete(recursive: true);
  });

  test('ajoute et persiste une tache', () async {
    await manager.addTask('Lire', Priority.low);
    final tasks = await repository.getAll();
    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Lire');
  });

  test('persiste les dates et les priorites', () async {
    final date = DateTime(2026, 10, 15);
    await manager.addTask('Rapport', Priority.high, dueDate: date);
    final task = (await repository.getAll()).single;
    expect(task.priority, Priority.high);
    expect(task.dueDate, date);
  });

  test('trie les taches par priorite', () async {
    await manager.addTask('Bas', Priority.low);
    await manager.addTask('Haut', Priority.high);
    final tasks = await manager.listTasks(sort: TaskSort.priority);
    expect(tasks.map((task) => task.title), ['Haut', 'Bas']);
  });

  test('termine une tache', () async {
    final task = await manager.addTask('Finir', Priority.medium);
    await manager.completeTask(task.id);
    expect((await repository.getAll()).single.isCompleted, isTrue);
  });

  test('supprime une tache', () async {
    final task = await manager.addTask('Supprimer', Priority.low);
    await manager.removeTask(task.id);
    expect(await repository.getAll(), isEmpty);
  });

  test('rejette un titre vide et une tache absente', () async {
    expect(
      () => manager.addTask('', Priority.low),
      throwsA(isA<InvalidTaskException>()),
    );
    expect(
      () => manager.completeTask('missing'),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('restaure une UrgentTask depuis JSON', () async {
    final task = UrgentTask(id: 'urgent-1', title: 'Incident');
    await repository.save(task);
    final restored = (await repository.getAll()).single;
    expect(restored, isA<UrgentTask>());
    expect(restored.priority, Priority.high);
  });
}
