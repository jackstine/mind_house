import 'package:equatable/equatable.dart';
import 'package:mind_house_app/models/tag.dart';

abstract class TagEvent extends Equatable {
  const TagEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllTags extends TagEvent {}

class CreateTag extends TagEvent {
  final String name;
  final String? color;

  const CreateTag({
    required this.name,
    this.color,
  });

  @override
  List<Object?> get props => [name, color];
}

class UpdateTag extends TagEvent {
  final Tag tag;

  const UpdateTag(this.tag);

  @override
  List<Object?> get props => [tag];
}

class DeleteTag extends TagEvent {
  final int tagId;

  const DeleteTag(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

class GetTagSuggestions extends TagEvent {
  final String prefix;
  final int limit;

  const GetTagSuggestions({
    required this.prefix,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [prefix, limit];
}

class SearchTags extends TagEvent {
  final String query;

  const SearchTags(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadMostUsedTags extends TagEvent {
  final int limit;

  const LoadMostUsedTags({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class IncrementTagUsage extends TagEvent {
  final int tagId;

  const IncrementTagUsage(this.tagId);

  @override
  List<Object?> get props => [tagId];
}