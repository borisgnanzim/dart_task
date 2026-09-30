class TaskException implements Exception {
  final String message;
  const TaskException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class InvalidTaskException extends TaskException {
  const InvalidTaskException(super.message);
}

class TaskNotFoundException extends TaskException {
  const TaskNotFoundException(super.message);
}

class TaskStorageException extends TaskException {
  const TaskStorageException(super.message);
}
