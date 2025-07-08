import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'base_event.dart';
import 'base_state.dart';
import 'crud_states.dart';

abstract class BaseBloc<Event extends BaseEvent, State extends BaseState>
    extends Bloc<Event, State> {
  final Logger _logger;

  BaseBloc(super.initialState, {String? loggerName})
      : _logger = Logger(loggerName ?? 'BaseBloc') {
    _logger.info('BaseBloc initialized');
  }

  void logInfo(String message) {
    _logger.info(message);
  }

  void logWarning(String message) {
    _logger.warning(message);
  }

  void logError(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  @override
  void onTransition(Transition<Event, State> transition) {
    super.onTransition(transition);
    _logger.fine('Transition: ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    _logger.severe('BLoC Error', error, stackTrace);
  }

  @override
  Future<void> close() {
    _logger.info('BaseBloc closed');
    return super.close();
  }

  bool get isLoading => state is LoadingState || state is CrudLoadingState;
  bool get hasError => state is ErrorState || state is CrudErrorState;
  bool get isInitial => state is InitialState || state is CrudInitialState;
}