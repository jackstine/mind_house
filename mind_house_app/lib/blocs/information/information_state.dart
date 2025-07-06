import 'package:equatable/equatable.dart';
import 'package:mind_house_app/models/information.dart';

abstract class InformationState extends Equatable {
  const InformationState();

  @override
  List<Object?> get props => [];
}

class InformationInitial extends InformationState {}

class InformationLoading extends InformationState {}

class InformationLoaded extends InformationState {
  final List<Information> information;

  const InformationLoaded(this.information);

  @override
  List<Object?> get props => [information];
}

class InformationError extends InformationState {
  final String message;

  const InformationError(this.message);

  @override
  List<Object?> get props => [message];
}

class InformationCreated extends InformationState {
  final Information information;

  const InformationCreated(this.information);

  @override
  List<Object?> get props => [information];
}

class InformationUpdated extends InformationState {
  final Information information;

  const InformationUpdated(this.information);

  @override
  List<Object?> get props => [information];
}

class InformationDeleted extends InformationState {
  final String informationId;

  const InformationDeleted(this.informationId);

  @override
  List<Object?> get props => [informationId];
}