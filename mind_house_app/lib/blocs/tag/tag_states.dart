import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/blocs/base/base_state.dart';

/// States for TagBloc
/// 
/// This file defines all possible states that the TagBloc can be in during
/// tag-related operations. States follow the BLoC pattern and extend base states.

// Initial State
class TagInitialState extends InitialState {
  const TagInitialState();
}

// Loading States
class TagLoadingState extends LoadingState {
  const TagLoadingState();
}

class TagSearchingState extends LoadingState {
  const TagSearchingState();
}

class TagSuggestionsLoadingState extends LoadingState {
  const TagSuggestionsLoadingState();
}

class TagAnalyticsLoadingState extends LoadingState {
  const TagAnalyticsLoadingState();
}

// Loaded States
class TagLoadedState extends LoadedState<Tag> {
  const TagLoadedState(super.data);
}

class TagsLoadedState extends LoadedState<List<Tag>> {
  const TagsLoadedState(super.data);

  /// Convenience getter for the loaded tags
  List<Tag> get tags => data;

  /// Check if any tags are loaded
  bool get hasTags => data.isNotEmpty;

  /// Get the number of loaded tags
  int get count => data.length;
}

class TagSuggestionsLoadedState extends LoadedState<List<Tag>> {
  final String query;

  const TagSuggestionsLoadedState(super.data, {required this.query});

  @override
  List<Object?> get props => [data, query];

  /// Convenience getter for the suggestions
  List<Tag> get suggestions => data;

  /// Check if any suggestions are available
  bool get hasSuggestions => data.isNotEmpty;

  /// Get the number of suggestions
  int get count => data.length;
}

class TagCountLoadedState extends LoadedState<int> {
  const TagCountLoadedState(super.data);

  /// Convenience getter for the count
  int get count => data;
}

class TagColorsLoadedState extends LoadedState<List<String>> {
  const TagColorsLoadedState(super.data);

  /// Convenience getter for the colors
  List<String> get colors => data;

  /// Check if any colors are in use
  bool get hasColors => data.isNotEmpty;

  /// Get the number of colors in use
  int get count => data.length;
}

// Creating States
class TagCreatingState extends CreatingState {
  const TagCreatingState();
}

class TagBulkCreatingState extends CreatingState {
  final int totalCount;

  const TagBulkCreatingState(this.totalCount);

  @override
  List<Object?> get props => [totalCount];
}

// Created States
class TagCreatedState extends CreatedState<Tag> {
  const TagCreatedState(super.data);

  /// Convenience getter for the created tag
  Tag get tag => data;
}

class TagBulkCreatedState extends CreatedState<List<Tag>> {
  const TagBulkCreatedState(super.data);

  /// Convenience getter for the created tags
  List<Tag> get tags => data;

  /// Get the number of created tags
  int get count => data.length;
}

// Updating States
class TagUpdatingState extends UpdatingState {
  const TagUpdatingState();
}

class TagUsageUpdatingState extends LoadingState {
  const TagUsageUpdatingState();
}

// Updated States
class TagUpdatedState extends UpdatedState<Tag> {
  const TagUpdatedState(super.data);

  /// Convenience getter for the updated tag
  Tag get tag => data;
}

class TagUsageUpdatedState extends BaseState {
  final String tagId;
  final int newUsageCount;

  const TagUsageUpdatedState(this.tagId, this.newUsageCount);

  @override
  List<Object?> get props => [tagId, newUsageCount];
}

class TagBulkUsageUpdatedState extends BaseState {
  final List<String> tagIds;

  const TagBulkUsageUpdatedState(this.tagIds);

  @override
  List<Object?> get props => [tagIds];
}

// Deleting States
class TagDeletingState extends DeletingState {
  const TagDeletingState();
}

// Deleted States
class TagDeletedState extends DeletedState {
  const TagDeletedState(super.id);
}

// Error States
class TagErrorState extends ErrorState {
  const TagErrorState(super.message, {super.exception});
}

class TagCreationErrorState extends ErrorState {
  final Tag? failedTag;

  const TagCreationErrorState(super.message, {super.exception, this.failedTag});

  @override
  List<Object?> get props => [message, exception, failedTag];
}

class TagUpdateErrorState extends ErrorState {
  final Tag? failedTag;

  const TagUpdateErrorState(super.message, {super.exception, this.failedTag});

  @override
  List<Object?> get props => [message, exception, failedTag];
}

class TagDeletionErrorState extends ErrorState {
  final String failedTagId;

  const TagDeletionErrorState(super.message, this.failedTagId, {super.exception});

  @override
  List<Object?> get props => [message, exception, failedTagId];
}

class TagSearchErrorState extends ErrorState {
  final String query;

  const TagSearchErrorState(super.message, this.query, {super.exception});

  @override
  List<Object?> get props => [message, exception, query];
}

class TagSuggestionsErrorState extends ErrorState {
  final String query;

  const TagSuggestionsErrorState(super.message, this.query, {super.exception});

  @override
  List<Object?> get props => [message, exception, query];
}

class TagValidationErrorState extends ErrorState {
  final String invalidName;

  const TagValidationErrorState(super.message, this.invalidName, {super.exception});

  @override
  List<Object?> get props => [message, exception, invalidName];
}

// Success States for Operations
class TagValidationSuccessState extends BaseState {
  final String validName;

  const TagValidationSuccessState(this.validName);

  @override
  List<Object?> get props => [validName];
}

class TagCacheClearedState extends BaseState {
  const TagCacheClearedState();
}

// Complex States for Advanced Operations
class TagAnalyticsLoadedState extends BaseState {
  final int totalTags;
  final int usedTags;
  final int unusedTags;
  final List<Tag> mostUsedTags;
  final List<Tag> recentlyUsedTags;
  final List<String> usedColors;

  const TagAnalyticsLoadedState({
    required this.totalTags,
    required this.usedTags,
    required this.unusedTags,
    required this.mostUsedTags,
    required this.recentlyUsedTags,
    required this.usedColors,
  });

  @override
  List<Object?> get props => [
    totalTags,
    usedTags,
    unusedTags,
    mostUsedTags,
    recentlyUsedTags,
    usedColors,
  ];

  /// Calculate usage percentage
  double get usagePercentage => totalTags > 0 ? (usedTags / totalTags) * 100 : 0.0;

  /// Check if tag analytics indicate healthy usage patterns
  bool get hasHealthyUsage => usagePercentage >= 60.0;
}