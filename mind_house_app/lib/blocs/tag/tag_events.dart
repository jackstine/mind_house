import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/blocs/base/base_event.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';

/// Events for TagBloc
/// 
/// This file defines all events that can be sent to the TagBloc for managing
/// tag-related operations in the Mind House application. Events follow the 
/// BLoC pattern and extend base events for consistency.

// Load Events
class LoadAllTagsEvent extends LoadEvent {
  final int? limit;
  final int? offset;

  const LoadAllTagsEvent({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}

class LoadTagByIdEvent extends LoadEvent {
  final String id;

  const LoadTagByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadTagByNameEvent extends LoadEvent {
  final String name;

  const LoadTagByNameEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class LoadSortedTagsEvent extends LoadEvent {
  final TagSortField sortBy;
  final SortOrder sortOrder;
  final int? limit;
  final int? offset;

  const LoadSortedTagsEvent({
    required this.sortBy,
    required this.sortOrder,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [sortBy, sortOrder, limit, offset];
}

// Search Events
class SearchTagsEvent extends BaseEvent {
  final String query;
  final int? limit;
  final int? offset;

  const SearchTagsEvent(this.query, {this.limit, this.offset});

  @override
  List<Object?> get props => [query, limit, offset];
}

class GetTagSuggestionsEvent extends BaseEvent {
  final String partialName;
  final int limit;

  const GetTagSuggestionsEvent(this.partialName, {this.limit = 5});

  @override
  List<Object?> get props => [partialName, limit];
}

class GetSmartTagSuggestionsEvent extends BaseEvent {
  final String partialName;
  final List<String> existingTagIds;
  final int limit;
  final bool includeRecentlyUsed;

  const GetSmartTagSuggestionsEvent(
    this.partialName, {
    this.existingTagIds = const [],
    this.limit = 5,
    this.includeRecentlyUsed = true,
  });

  @override
  List<Object?> get props => [partialName, existingTagIds, limit, includeRecentlyUsed];
}

class GetContextualSuggestionsEvent extends BaseEvent {
  final List<String> baseTagIds;
  final int limit;

  const GetContextualSuggestionsEvent(this.baseTagIds, {this.limit = 5});

  @override
  List<Object?> get props => [baseTagIds, limit];
}

class GetTrendingSuggestionsEvent extends BaseEvent {
  final int days;
  final int limit;

  const GetTrendingSuggestionsEvent({this.days = 30, this.limit = 5});

  @override
  List<Object?> get props => [days, limit];
}

class GetDiverseSuggestionsEvent extends BaseEvent {
  final List<String> excludeTagIds;
  final int limit;
  final int maxPerColor;

  const GetDiverseSuggestionsEvent({
    this.excludeTagIds = const [],
    this.limit = 5,
    this.maxPerColor = 2,
  });

  @override
  List<Object?> get props => [excludeTagIds, limit, maxPerColor];
}

// Filter Events
class LoadTagsByColorEvent extends LoadEvent {
  final String color;
  final int? limit;
  final int? offset;

  const LoadTagsByColorEvent(this.color, {this.limit, this.offset});

  @override
  List<Object?> get props => [color, limit, offset];
}

class LoadFrequentlyUsedTagsEvent extends LoadEvent {
  final int threshold;
  final int? limit;

  const LoadFrequentlyUsedTagsEvent({this.threshold = 10, this.limit});

  @override
  List<Object?> get props => [threshold, limit];
}

class LoadUnusedTagsEvent extends LoadEvent {
  final int? limit;

  const LoadUnusedTagsEvent({this.limit});

  @override
  List<Object?> get props => [limit];
}

class LoadRecentlyUsedTagsEvent extends LoadEvent {
  final int days;
  final int limit;

  const LoadRecentlyUsedTagsEvent({this.days = 7, this.limit = 10});

  @override
  List<Object?> get props => [days, limit];
}

// CRUD Events
class CreateTagEvent extends CreateEvent {
  final Tag tag;

  const CreateTagEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}

class CreateTagFromInputEvent extends CreateEvent {
  final String input;
  final String? color;

  const CreateTagFromInputEvent(this.input, {this.color});

  @override
  List<Object?> get props => [input, color];
}

class UpdateTagEvent extends UpdateEvent {
  final Tag tag;

  const UpdateTagEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}

class DeleteTagEvent extends DeleteEvent {
  final String id;

  const DeleteTagEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// Usage Events
class IncrementTagUsageEvent extends BaseEvent {
  final String id;

  const IncrementTagUsageEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateTagLastUsedEvent extends BaseEvent {
  final String id;

  const UpdateTagLastUsedEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// Bulk Operations Events
class BulkCreateTagsEvent extends CreateEvent {
  final List<Tag> tags;

  const BulkCreateTagsEvent(this.tags);

  @override
  List<Object?> get props => [tags];
}

class BulkIncrementUsageEvent extends BaseEvent {
  final List<String> tagIds;

  const BulkIncrementUsageEvent(this.tagIds);

  @override
  List<Object?> get props => [tagIds];
}

// Analytics Events
class LoadTagCountEvent extends LoadEvent {
  final bool? hasUsage;
  final String? color;
  final int? minUsageCount;

  const LoadTagCountEvent({this.hasUsage, this.color, this.minUsageCount});

  @override
  List<Object?> get props => [hasUsage, color, minUsageCount];
}

class LoadUsedColorsEvent extends LoadEvent {
  const LoadUsedColorsEvent();
}

// Utility Events
class RefreshTagsEvent extends RefreshEvent {
  const RefreshTagsEvent();
}

class ClearTagCacheEvent extends BaseEvent {
  const ClearTagCacheEvent();
}

class ValidateTagEvent extends BaseEvent {
  final String name;

  const ValidateTagEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class LoadTagAnalyticsEvent extends LoadEvent {
  const LoadTagAnalyticsEvent();
}