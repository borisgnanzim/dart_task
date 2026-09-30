import 'dart:io';

import 'package:dart_task/dart_task.dart';

Future<void> main(List<String> arguments) async {
  final manager = TaskManager(JsonTaskRepository('tasks.json'));
  if (arguments.isNotEmpty) {
    try {
      await _handle(arguments.join(' '), manager);
    } on TaskException catch (error) {
      print(error);
    } on FormatException {
      print('Format invalide. Consultez "help".');
    }
    await manager.dispose();
    return;
  }

  print('Gestionnaire de taches. Tapez "help" pour commencer.');
  while (true) {
    stdout.write('> ');
    final input = stdin.readLineSync()?.trim() ?? 'quit';
    if (input == 'quit' || input == 'exit') break;
    try {
      await _handle(input, manager);
    } on TaskException catch (error) {
      print(error);
    } on FormatException {
      print('Format invalide. Consultez "help".');
    }
  }
  await manager.dispose();
}

Future<void> _handle(String input, TaskManager manager) async {
  final parts = input.split(RegExp(r'\s+'));
  final command = parts.first.toLowerCase();
  switch (command) {
    case 'help':
      print('add <titre> [low|medium|high] [YYYY-MM-DD] [urgent]');
      print(
        'list [priority|date] | done/complete <id> | delete/remove <id> | quit',
      );
    case 'add':
      if (parts.length < 2) throw const InvalidTaskException('Titre requis.');
      final titleParts = parts.sublist(1);
      DateTime? dueDate;
      var urgent = false;
      if (titleParts.isNotEmpty && titleParts.last.toLowerCase() == 'urgent') {
        urgent = true;
        titleParts.removeLast();
      }
      if (titleParts.isNotEmpty && _isDate(titleParts.last)) {
        dueDate = DateTime.parse(titleParts.removeLast());
      }
      var priority = Priority.medium;
      if (titleParts.isNotEmpty && _isPriority(titleParts.last)) {
        priority = priorityFromString(titleParts.removeLast());
      }
      final title = titleParts.join(' ').replaceAll('"', '').trim();
      final task = await manager.addTask(
        title,
        priority,
        dueDate: dueDate,
        urgent: urgent,
      );
      print('Tache ajoutee: ${task.id}');
    case 'list':
      if (parts.length > 1 && parts[1] != 'priority' && parts[1] != 'date') {
        throw const InvalidTaskException('Tri invalide: priority ou date.');
      }
      final sort =
          parts.length > 1 && parts[1] == 'priority'
              ? TaskSort.priority
              : parts.length > 1 && parts[1] == 'date'
              ? TaskSort.dueDate
              : null;
      for (final task in await manager.listTasks(sort: sort)) {
        final status = task.isCompleted ? 'x' : ' ';
        print('[$status] ${task.id} | ${task.summary}');
      }
    case 'done' || 'complete':
      if (parts.length < 2) {
        throw const InvalidTaskException('Identifiant requis.');
      }
      await manager.completeTask(parts[1]);
      print('Tache terminee.');
    case 'delete' || 'remove':
      if (parts.length < 2) {
        throw const InvalidTaskException('Identifiant requis.');
      }
      await manager.removeTask(parts[1]);
      print('Tache supprimee.');
    default:
      print('Commande inconnue. Tapez "help".');
  }
}

bool _isDate(String value) => RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);

bool _isPriority(String value) =>
    Priority.values.any((priority) => priority.name == value.toLowerCase());
