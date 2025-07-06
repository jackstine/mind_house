import 'package:equatable/equatable.dart';

abstract class TagSuggestionEvent extends Equatable {
  const TagSuggestionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTagSuggestions extends TagSuggestionEvent {
  final String prefix;
  final int limit;

  const LoadTagSuggestions({
    required this.prefix,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [prefix, limit];
}

class ClearTagSuggestions extends TagSuggestionEvent {}

class SelectTagSuggestion extends TagSuggestionEvent {
  final String tagName;

  const SelectTagSuggestion(this.tagName);

  @override
  List<Object?> get props => [tagName];
}