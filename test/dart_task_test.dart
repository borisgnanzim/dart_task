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

  test(
    'trie les taches par date et place les dates absentes a la fin',
    () async {
      await manager.addTask('Sans date', Priority.low);
      await manager.addTask(
        'Plus tard',
        Priority.low,
        dueDate: DateTime(2026, 12, 1),
      );
      await manager.addTask(
        'Bientot',
        Priority.low,
        dueDate: DateTime(2026, 10, 1),
      );
      final tasks = await manager.listTasks(sort: TaskSort.dueDate);
      expect(tasks.map((task) => task.title), [
        'Bientot',
        'Plus tard',
        'Sans date',
      ]);
    },
  );

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

  test('une tache urgente utilise la priorite high', () async {
    final task = await manager.addTask('Incident', Priority.low, urgent: true);
    expect(task, isA<UrgentTask>());
    expect(task.priority, Priority.high);
  });

  test('transforme un JSON corrompu en exception personnalisee', () async {
    final file = File('${tempDirectory.path}/tasks.json');
    await file.writeAsString('{"not": "a list"}');
    expect(repository.getAll(), throwsA(isA<TaskStorageException>()));
  });

  test('normalise le titre et refuse un identifiant vide', () {
    final task = StandardTask(
      id: 'task-1',
      title: '  Titre  ',
      priority: Priority.low,
    );
    expect(task.title, 'Titre');
    expect(
      () => StandardTask(id: '', title: 'Titre', priority: Priority.low),
      throwsA(isA<InvalidTaskException>()),
    );
  });

  test('expose les changements via un StreamController', () async {
    final events = <TaskEvent>[];
    final subscription = manager.events.listen(events.add);
    final task = await manager.addTask('Suivi', Priority.medium);
    await manager.completeTask(task.id);
    await manager.removeTask(task.id);
    await Future<void>.delayed(Duration.zero);
    expect(events.map((event) => event.type), [
      TaskEventType.added,
      TaskEventType.completed,
      TaskEventType.deleted,
    ]);
    await subscription.cancel();
  });

  test('l extension signale une tache en retard', () {
    final task = StandardTask(
      id: 'late-1',
      title: 'En retard',
      priority: Priority.high,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    expect(task.isOverdue, isTrue);
    expect(task.summary, contains('En retard'));
  });
}
