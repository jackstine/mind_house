import 'package:equatable/equatable.dart';
import 'package:mind_house_app/models/information.dart';

abstract class InformationEvent extends Equatable {
  const InformationEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllInformation extends InformationEvent {}

class CreateInformation extends InformationEvent {
  final String content;
  final List<String> tagNames;

  const CreateInformation({
    required this.content,
    required this.tagNames,
  });

  @override
  List<Object?> get props => [content, tagNames];
}

class UpdateInformation extends InformationEvent {
  final Information information;
  final List<String> tagNames;

  const UpdateInformation({
    required this.information,
    required this.tagNames,
  });

  @override
  List<Object?> get props => [information, tagNames];
}

class DeleteInformation extends InformationEvent {
  final String informationId;

  const DeleteInformation(this.informationId);

  @override
  List<Object?> get props => [informationId];
}

class SearchInformation extends InformationEvent {
  final String query;

  const SearchInformation(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterInformationByTags extends InformationEvent {
  final List<int> tagIds;

  const FilterInformationByTags(this.tagIds);

  @override
  List<Object?> get props => [tagIds];
}

class LoadInformationById extends InformationEvent {
  final String informationId;

  const LoadInformationById(this.informationId);

  @override
  List<Object?> get props => [informationId];
}