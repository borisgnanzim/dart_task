import 'task.dart';

extension TaskPresentation on Task {
  String get statusLabel => isCompleted ? 'terminee' : 'a faire';

  bool get isOverdue =>
      !isCompleted && dueDate != null && dueDate!.isBefore(DateTime.now());

  String get summary {
    final date = dueDate?.toIso8601String().split('T').first ?? '-';
    return '[$statusLabel] $title | ${priority.name} | $date';
  }
}
