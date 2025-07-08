import 'package:equatable/equatable.dart';

abstract class BaseEvent extends Equatable {
  const BaseEvent();

  @override
  List<Object?> get props => [];
}

abstract class LoadEvent extends BaseEvent {
  const LoadEvent();
}

abstract class CreateEvent extends BaseEvent {
  const CreateEvent();
}

abstract class UpdateEvent extends BaseEvent {
  const UpdateEvent();
}

abstract class DeleteEvent extends BaseEvent {
  const DeleteEvent();
}

abstract class RefreshEvent extends BaseEvent {
  const RefreshEvent();
}