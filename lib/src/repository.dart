import 'dart:convert';
import 'dart:io';

import 'exceptions.dart';
import 'task.dart';

abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<void> save(T item);
  Future<void> delete(String id);
}

class JsonTaskRepository implements Repository<Task> {
  final File file;

  JsonTaskRepository(String path) : file = File(path);

  @override
  Future<List<Task>> getAll() async {
    if (!await file.exists()) return [];
    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      final decoded = jsonDecode(content);
      if (decoded is! List<dynamic>) {
        throw const TaskStorageException(
          'Le fichier JSON doit contenir une liste.',
        );
      }
      final data = decoded;
      return data
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TaskStorageException {
      rethrow;
    } on TaskException catch (error) {
      throw TaskStorageException('Donnees invalides: ${error.message}');
    } on FormatException catch (error) {
      throw TaskStorageException('JSON invalide: ${error.message}');
    } on IOException catch (error) {
      throw TaskStorageException('Lecture impossible: $error');
    } catch (error) {
      throw TaskStorageException('Donnees invalides: $error');
    }
  }

  @override
  Future<void> save(Task item) async {
    final tasks = await getAll();
    final index = tasks.indexWhere((task) => task.id == item.id);
    if (index == -1) {
      tasks.add(item);
    } else {
      tasks[index] = item;
    }
    await _write(tasks);
  }

  @override
  Future<void> delete(String id) async {
    final tasks = await getAll();
    tasks.removeWhere((task) => task.id == id);
    await _write(tasks);
  }

  Future<void> _write(List<Task> tasks) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(tasks.map((task) => task.toJson()).toList()),
      );
    } on IOException catch (error) {
      throw TaskStorageException('Ecriture impossible: $error');
    }
  }
}
