import 'package:equatable/equatable.dart';

abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

abstract class InitialState extends BaseState {
  const InitialState();
}

abstract class LoadingState extends BaseState {
  const LoadingState();
}

abstract class LoadedState<T> extends BaseState {
  final T data;

  const LoadedState(this.data);

  @override
  List<Object?> get props => [data];
}

abstract class ErrorState extends BaseState {
  final String message;
  final Exception? exception;

  const ErrorState(this.message, {this.exception});

  @override
  List<Object?> get props => [message, exception];
}

abstract class CreatingState extends BaseState {
  const CreatingState();
}

abstract class CreatedState<T> extends BaseState {
  final T data;

  const CreatedState(this.data);

  @override
  List<Object?> get props => [data];
}

abstract class UpdatingState extends BaseState {
  const UpdatingState();
}

abstract class UpdatedState<T> extends BaseState {
  final T data;

  const UpdatedState(this.data);

  @override
  List<Object?> get props => [data];
}

abstract class DeletingState extends BaseState {
  const DeletingState();
}

abstract class DeletedState extends BaseState {
  final String id;

  const DeletedState(this.id);

  @override
  List<Object?> get props => [id];
}