import 'exceptions.dart';

enum Priority { low, medium, high }

typedef TaskFields =
    ({
      String id,
      String title,
      Priority priority,
      DateTime? dueDate,
      bool isCompleted,
    });

Priority priorityFromString(String value) {
  return Priority.values.firstWhere(
    (priority) => priority.name == value.toLowerCase(),
    orElse: () => throw InvalidTaskException('Priorite invalide: $value'),
  );
}

abstract class Task {
  final String id;
  final String title;
  final Priority priority;
  final DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required String title,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
  }) : title = title.trim() {
    if (id.trim().isEmpty) {
      throw const InvalidTaskException('Identifiant invalide.');
    }
    if (title.trim().isEmpty) {
      throw const InvalidTaskException('Le titre ne peut pas etre vide.');
    }
  }

  String get type;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'priority': priority.name,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'type': type,
  };

  static Task fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'standard';
    final (:id, :title, :priority, :dueDate, :isCompleted) = _readTaskFields(
      json,
    );
    if (type == 'urgent') {
      return UrgentTask(
        id: id,
        title: title,
        priority: priority,
        dueDate: dueDate,
        isCompleted: isCompleted,
      );
    }
    return StandardTask(
      id: id,
      title: title,
      priority: priority,
      dueDate: dueDate,
      isCompleted: isCompleted,
    );
  }
}

TaskFields _readTaskFields(Map<String, dynamic> json) {
  final dueDateValue = json['dueDate'];
  return (
    id: json['id'] as String,
    title: json['title'] as String,
    priority: priorityFromString(json['priority'] as String),
    dueDate:
        dueDateValue == null ? null : DateTime.parse(dueDateValue as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

class StandardTask extends Task {
  StandardTask({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.isCompleted,
  });

  @override
  String get type => 'standard';
}

class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    super.priority = Priority.high,
    super.dueDate,
    super.isCompleted,
  });

  @override
  String get type => 'urgent';
}
