import '../base/crud_states.dart';
import '../../models/information.dart';
import '../../models/information_tag.dart';

/// Information-specific states extending the base CRUD states
/// 
/// These states provide specialized state management for Information entities
/// including states for filtering, counting, and tag operations.

/// State representing that information items were loaded by type
class InformationLoadedByTypeState extends CrudState {
  final List<Information> informationItems;
  final InformationType type;

  const InformationLoadedByTypeState(this.informationItems, this.type);

  @override
  List<Object?> get props => [informationItems, type];
}

/// State representing that favorite information items were loaded
class FavoritesLoadedState extends CrudState {
  final List<Information> favorites;

  const FavoritesLoadedState(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

/// State representing that archived information items were loaded
class ArchivedLoadedState extends CrudState {
  final List<Information> archived;

  const ArchivedLoadedState(this.archived);

  @override
  List<Object?> get props => [archived];
}

/// State representing that recently accessed information items were loaded
class RecentlyAccessedLoadedState extends CrudState {
  final List<Information> recentlyAccessed;

  const RecentlyAccessedLoadedState(this.recentlyAccessed);

  @override
  List<Object?> get props => [recentlyAccessed];
}

/// State representing that information items were loaded by importance
class InformationLoadedByImportanceState extends CrudState {
  final List<Information> informationItems;
  final int minImportance;
  final int? maxImportance;

  const InformationLoadedByImportanceState(
    this.informationItems,
    this.minImportance,
    this.maxImportance,
  );

  @override
  List<Object?> get props => [informationItems, minImportance, maxImportance];
}

/// State representing that an information item was marked as accessed
class MarkedAsAccessedState extends CrudState {
  final String informationId;

  const MarkedAsAccessedState(this.informationId);

  @override
  List<Object?> get props => [informationId];
}

/// State representing information count result
class InformationCountState extends CrudState {
  final int count;
  final InformationType? type;
  final bool? isFavorite;
  final bool? isArchived;

  const InformationCountState(
    this.count, {
    this.type,
    this.isFavorite,
    this.isArchived,
  });

  @override
  List<Object?> get props => [count, type, isFavorite, isArchived];
}

/// State representing that information items were loaded by tag IDs
class InformationLoadedByTagIdsState extends CrudState {
  final List<Information> informationItems;
  final List<String> tagIds;
  final bool requireAllTags;

  const InformationLoadedByTagIdsState(
    this.informationItems,
    this.tagIds,
    this.requireAllTags,
  );

  @override
  List<Object?> get props => [informationItems, tagIds, requireAllTags];
}

/// State representing that tags were successfully added to an information item
class TagsAddedState extends CrudState {
  final String informationId;
  final List<String> tagIds;

  const TagsAddedState(this.informationId, this.tagIds);

  @override
  List<Object?> get props => [informationId, tagIds];
}

/// State representing that tags were successfully removed from an information item
class TagsRemovedState extends CrudState {
  final String informationId;
  final List<String> tagIds;

  const TagsRemovedState(this.informationId, this.tagIds);

  @override
  List<Object?> get props => [informationId, tagIds];
}

/// State representing that tags were successfully updated for an information item
class TagsUpdatedState extends CrudState {
  final String informationId;
  final List<String> tagIds;

  const TagsUpdatedState(this.informationId, this.tagIds);

  @override
  List<Object?> get props => [informationId, tagIds];
}

/// State representing that tag assignments were loaded for an information item
class TagAssignmentsLoadedState extends CrudState {
  final String informationId;
  final List<InformationTag> assignments;

  const TagAssignmentsLoadedState(this.informationId, this.assignments);

  @override
  List<Object?> get props => [informationId, assignments];
}

/// State representing that tag IDs were loaded for an information item
class TagIdsLoadedState extends CrudState {
  final String informationId;
  final List<String> tagIds;

  const TagIdsLoadedState(this.informationId, this.tagIds);

  @override
  List<Object?> get props => [informationId, tagIds];
}

/// State representing that a tag operation is in progress
class TagOperationInProgressState extends CrudState {
  final String informationId;
  final String operation; // "adding", "removing", "updating"

  const TagOperationInProgressState(this.informationId, this.operation);

  @override
  List<Object?> get props => [informationId, operation];
}