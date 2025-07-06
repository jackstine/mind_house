class RepositoryException implements Exception {
  final String message;
  final dynamic cause;

  const RepositoryException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'RepositoryException: $message\nCaused by: $cause';
    }
    return 'RepositoryException: $message';
  }
}