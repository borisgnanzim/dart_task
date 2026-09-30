import 'package:dart_task/src/exceptions.dart';
import 'package:dart_task/src/repository.dart';
import 'package:dart_task/src/task.dart';

enum TaskSort { priority, dueDate }

class TaskManager {
  final Repository<Task> repository;

  TaskManager(this.repository);

  Future<Task> addTask(
    String title,
    Priority priority, {
    DateTime? dueDate,
    bool urgent = false,
  }) async {
    final taskPriority = urgent ? Priority.high : priority;
    final task =
        urgent
            ? UrgentTask(
              id: _newId(),
              title: title,
              priority: taskPriority,
              dueDate: dueDate,
            )
            : StandardTask(
              id: _newId(),
              title: title,
              priority: taskPriority,
              dueDate: dueDate,
            );
    await repository.save(task);
    return task;
  }

  Future<List<Task>> listTasks({TaskSort? sort}) async {
    final tasks = List<Task>.of(await repository.getAll());
    if (sort == TaskSort.priority) {
      tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    } else if (sort == TaskSort.dueDate) {
      tasks.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    }
    return tasks;
  }

  Future<void> completeTask(String id) async {
    final task = await _find(id);
    task.isCompleted = true;
    await repository.save(task);
  }

  Future<void> markAsCompleted(String id) => completeTask(id);

  Future<void> removeTask(String id) async {
    await _find(id);
    await repository.delete(id);
  }

  Future<void> deleteTask(String id) => removeTask(id);

  Future<Task> _find(String id) async {
    final tasks = await repository.getAll();
    try {
      return tasks.firstWhere((task) => task.id == id);
    } on StateError {
      throw TaskNotFoundException('Tache introuvable: $id');
    }
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
