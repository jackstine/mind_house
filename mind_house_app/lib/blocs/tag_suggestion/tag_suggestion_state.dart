import 'package:equatable/equatable.dart';
import 'package:mind_house_app/models/tag.dart';

abstract class TagSuggestionState extends Equatable {
  const TagSuggestionState();

  @override
  List<Object?> get props => [];
}

class TagSuggestionInitial extends TagSuggestionState {}

class TagSuggestionLoading extends TagSuggestionState {}

class TagSuggestionLoaded extends TagSuggestionState {
  final List<Tag> suggestions;
  final String query;

  const TagSuggestionLoaded({
    required this.suggestions,
    required this.query,
  });

  @override
  List<Object?> get props => [suggestions, query];
}

class TagSuggestionEmpty extends TagSuggestionState {
  final String query;

  const TagSuggestionEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

class TagSuggestionError extends TagSuggestionState {
  final String message;

  const TagSuggestionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TagSuggestionSelected extends TagSuggestionState {
  final String selectedTag;

  const TagSuggestionSelected(this.selectedTag);

  @override
  List<Object?> get props => [selectedTag];
}