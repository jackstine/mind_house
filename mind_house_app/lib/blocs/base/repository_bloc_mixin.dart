import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_event.dart';
import 'base_state.dart';

mixin RepositoryBlocMixin<Event extends BaseEvent, State extends BaseState>
    on Bloc<Event, State> {
  
  Future<T> safeRepositoryCall<T>(
    Future<T> Function() repositoryCall,
    State Function(String message, Exception? exception) errorStateBuilder,
  ) async {
    try {
      return await repositoryCall();
    } catch (e) {
      final exception = e is Exception ? e : Exception(e.toString());
      emit(errorStateBuilder('Repository operation failed: ${e.toString()}', exception));
      throw exception;
    }
  }

  void handleRepositoryError(
    Object error,
    StackTrace stackTrace,
    State Function(String message, Exception? exception) errorStateBuilder,
  ) {
    final exception = error is Exception ? error : Exception(error.toString());
    final message = 'Unexpected error: ${error.toString()}';
    emit(errorStateBuilder(message, exception));
  }
}