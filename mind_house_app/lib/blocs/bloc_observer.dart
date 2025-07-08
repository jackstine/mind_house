import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

class MindHouseBlocObserver extends BlocObserver {
  final Logger _logger = Logger('BlocObserver');

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.info('BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(BlocBase bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.fine('Event: ${bloc.runtimeType} - ${event.runtimeType}');
  }

  @override
  void onTransition(BlocBase bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _logger.fine('Transition: ${bloc.runtimeType} - ${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.fine('Change: ${bloc.runtimeType} - ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.severe('Error: ${bloc.runtimeType}', error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _logger.info('BLoC Closed: ${bloc.runtimeType}');
  }
}