import '../base/crud_events.dart';
import '../../models/information.dart';

/// Information-specific events extending the base CRUD events
/// 
/// These events provide specialized functionality for Information entities
/// beyond the standard CRUD operations, including filtering by type, importance,
/// favorites, archives, and tag-based operations.

/// Event to load information items by type
class LoadByTypeEvent extends CrudEvent {
  final InformationType type;
  final int? limit;
  final int? offset;

  const LoadByTypeEvent(this.type, {this.limit, this.offset});

  @override
  List<Object?> get props => [type, limit, offset];
}

/// Event to load favorite information items
class LoadFavoritesEvent extends CrudEvent {
  final int? limit;
  final int? offset;

  const LoadFavoritesEvent({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}

/// Event to load archived information items
class LoadArchivedEvent extends CrudEvent {
  final int? limit;
  final int? offset;

  const LoadArchivedEvent({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}

/// Event to load recently accessed information items
class LoadRecentlyAccessedEvent extends CrudEvent {
  final int limit;

  const LoadRecentlyAccessedEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Event to load information items by importance level
class LoadByImportanceEvent extends CrudEvent {
  final int minImportance;
  final int? maxImportance;
  final int? limit;
  final int? offset;

  const LoadByImportanceEvent(
    this.minImportance, {
    this.maxImportance,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [minImportance, maxImportance, limit, offset];
}

/// Event to mark an information item as accessed
class MarkAsAccessedEvent extends CrudEvent {
  final String informationId;

  const MarkAsAccessedEvent(this.informationId);

  @override
  List<Object?> get props => [informationId];
}

/// Event to get count of information items with optional filters
class GetCountEvent extends CrudEvent {
  final InformationType? type;
  final bool? isFavorite;
  final bool? isArchived;

  const GetCountEvent({this.type, this.isFavorite, this.isArchived});

  @override
  List<Object?> get props => [type, isFavorite, isArchived];
}

/// Event to load information items by tag IDs
class LoadByTagIdsEvent extends CrudEvent {
  final List<String> tagIds;
  final bool requireAllTags;
  final int? limit;
  final int? offset;

  const LoadByTagIdsEvent(
    this.tagIds, {
    this.requireAllTags = false,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [tagIds, requireAllTags, limit, offset];
}

/// Event to add tags to an information item
class AddTagsEvent extends CrudEvent {
  final String informationId;
  final List<String> tagIds;

  const AddTagsEvent(this.informationId, this.tagIds);

  @override
  List<Object?> get props => [informationId, tagIds];
}

/// Event to remove tags from an information item
class RemoveTagsEvent extends CrudEvent {
  final String informationId;
  final List<String> tagIds;

  const RemoveTagsEvent(this.informationId, this.tagIds);

  @override
  List<Object?> get props => [informationId, tagIds];
}

/// Event to update all tags for an information item
class UpdateTagsEvent extends CrudEvent {
  final String informationId;
  final List<String> tagIds;

  const UpdateTagsEvent(this.informationId, this.tagIds);

  @override
  List<Object?> get props => [informationId, tagIds];
}

/// Event to load tag assignments for an information item
class LoadTagAssignmentsEvent extends CrudEvent {
  final String informationId;

  const LoadTagAssignmentsEvent(this.informationId);

  @override
  List<Object?> get props => [informationId];
}

/// Event to load tag IDs for an information item
class LoadTagIdsEvent extends CrudEvent {
  final String informationId;

  const LoadTagIdsEvent(this.informationId);

  @override
  List<Object?> get props => [informationId];
}