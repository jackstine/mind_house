import 'package:equatable/equatable.dart';
import 'package:mind_house_app/models/tag.dart';

abstract class TagState extends Equatable {
  const TagState();

  @override
  List<Object?> get props => [];
}

class TagInitial extends TagState {}

class TagLoading extends TagState {}

class TagLoaded extends TagState {
  final List<Tag> tags;

  const TagLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

class TagError extends TagState {
  final String message;

  const TagError(this.message);

  @override
  List<Object?> get props => [message];
}

class TagCreated extends TagState {
  final Tag tag;

  const TagCreated(this.tag);

  @override
  List<Object?> get props => [tag];
}

class TagUpdated extends TagState {
  final Tag tag;

  const TagUpdated(this.tag);

  @override
  List<Object?> get props => [tag];
}

class TagDeleted extends TagState {
  final int tagId;

  const TagDeleted(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

class TagSuggestions extends TagState {
  final List<Tag> suggestions;

  const TagSuggestions(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

class TagUsageIncremented extends TagState {
  final int tagId;

  const TagUsageIncremented(this.tagId);

  @override
  List<Object?> get props => [tagId];
}