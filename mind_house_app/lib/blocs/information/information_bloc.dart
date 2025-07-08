import 'package:flutter_bloc/flutter_bloc.dart';
import '../base/crud_bloc.dart';
import '../base/crud_events.dart';
import '../base/crud_states.dart';
import 'information_events.dart';
import 'information_states.dart';
import '../../models/information.dart';
import '../../models/information_tag.dart';
import '../../repositories/information_repository.dart';

/// BLoC for managing Information entities with comprehensive CRUD operations
/// 
/// This BLoC extends the base CrudBloc to provide specialized functionality
/// for Information entities, including filtering, searching, tag management,
/// and various domain-specific operations like favorites, archives, and importance.
/// 
/// The InformationBloc follows the Mind House application's tags-first approach
/// and provides efficient state management for all information-related operations.
class InformationBloc extends CrudBloc<Information> {
  final InformationRepository _repository;

  /// Create a new InformationBloc with the specified repository
  /// 
  /// [repository] - The repository for Information data operations
  InformationBloc(this._repository) : super(loggerName: 'InformationBloc') {
    // Register Information-specific event handlers
    on<LoadByTypeEvent>(_onLoadByType);
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<LoadArchivedEvent>(_onLoadArchived);
    on<LoadRecentlyAccessedEvent>(_onLoadRecentlyAccessed);
    on<LoadByImportanceEvent>(_onLoadByImportance);
    on<MarkAsAccessedEvent>(_onMarkAsAccessed);
    on<GetCountEvent>(_onGetCount);
    on<LoadByTagIdsEvent>(_onLoadByTagIds);
    on<AddTagsEvent>(_onAddTags);
    on<RemoveTagsEvent>(_onRemoveTags);
    on<UpdateTagsEvent>(_onUpdateTags);
    on<LoadTagAssignmentsEvent>(_onLoadTagAssignments);
    on<LoadTagIdsEvent>(_onLoadTagIds);
  }

  // ============================================================================
  // CRUD Operations Implementation
  // ============================================================================

  @override
  Future<List<Information>> getAllItems() async {
    return await _repository.getAll();
  }

  @override
  Future<Information?> getItemById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<Information> createItem(Information item) async {
    await _repository.create(item);
    return item;
  }

  @override
  Future<Information> updateItem(Information item) async {
    final success = await _repository.update(item);
    if (!success) {
      throw Exception('Failed to update information item');
    }
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    final success = await _repository.delete(id);
    if (!success) {
      throw Exception('Failed to delete information item');
    }
  }

  @override
  Future<List<Information>> searchItems(String query) async {
    return await _repository.search(query);
  }

  @override
  Future<List<Information>> filterItems(dynamic filter) async {
    if (filter is InformationType) {
      return await _repository.getByType(filter);
    } else if (filter is Map<String, dynamic>) {
      // Handle complex filters
      if (filter.containsKey('type')) {
        return await _repository.getByType(filter['type'] as InformationType);
      }
      if (filter.containsKey('isFavorite') && filter['isFavorite'] == true) {
        return await _repository.getFavorites();
      }
      if (filter.containsKey('isArchived') && filter['isArchived'] == true) {
        return await _repository.getArchived();
      }
      if (filter.containsKey('tagIds')) {
        final tagIds = filter['tagIds'] as List<String>;
        final requireAllTags = filter['requireAllTags'] as bool? ?? false;
        return await _repository.getByTagIds(tagIds, requireAllTags: requireAllTags);
      }
    }
    
    // Fallback to getting all items
    return await getAllItems();
  }

  // ============================================================================
  // Information-Specific Event Handlers
  // ============================================================================

  /// Handle loading information items by type
  Future<void> _onLoadByType(LoadByTypeEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final informationItems = await _repository.getByType(
        event.type,
        limit: event.limit,
        offset: event.offset,
      );
      emit(InformationLoadedByTypeState(informationItems, event.type));
      logInfo('Loaded ${informationItems.length} information items of type ${event.type.value}');
    } catch (e, stackTrace) {
      logError('Failed to load information by type: ${event.type.value}', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to load information by type: ${e.toString()}', exception: exception));
    }
  }

  /// Handle loading favorite information items
  Future<void> _onLoadFavorites(LoadFavoritesEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final favorites = await _repository.getFavorites(
        limit: event.limit,
        offset: event.offset,
      );
      emit(FavoritesLoadedState(favorites));
      logInfo('Loaded ${favorites.length} favorite information items');
    } catch (e, stackTrace) {
      logError('Failed to load favorite information items', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to load favorites: ${e.toString()}', exception: exception));
    }
  }

  /// Handle loading archived information items
  Future<void> _onLoadArchived(LoadArchivedEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final archived = await _repository.getArchived(
        limit: event.limit,
        offset: event.offset,
      );
      emit(ArchivedLoadedState(archived));
      logInfo('Loaded ${archived.length} archived information items');
    } catch (e, stackTrace) {
      logError('Failed to load archived information items', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to load archived items: ${e.toString()}', exception: exception));
    }
  }

  /// Handle loading recently accessed information items
  Future<void> _onLoadRecentlyAccessed(LoadRecentlyAccessedEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final recentlyAccessed = await _repository.getRecentlyAccessed(limit: event.limit);
      emit(RecentlyAccessedLoadedState(recentlyAccessed));
      logInfo('Loaded ${recentlyAccessed.length} recently accessed information items');
    } catch (e, stackTrace) {
      logError('Failed to load recently accessed information items', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to load recently accessed items: ${e.toString()}', exception: exception));
    }
  }

  /// Handle loading information items by importance
  Future<void> _onLoadByImportance(LoadByImportanceEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final informationItems = await _repository.getByImportance(
        event.minImportance,
        maxImportance: event.maxImportance,
        limit: event.limit,
        offset: event.offset,
      );
      emit(InformationLoadedByImportanceState(
        informationItems,
        event.minImportance,
        event.maxImportance,
      ));
      logInfo('Loaded ${informationItems.length} information items by importance '
               '(${event.minImportance}-${event.maxImportance ?? 'max'})');
    } catch (e, stackTrace) {
      logError('Failed to load information by importance', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to load information by importance: ${e.toString()}', exception: exception));
    }
  }

  /// Handle marking an information item as accessed
  Future<void> _onMarkAsAccessed(MarkAsAccessedEvent event, Emitter<CrudState> emit) async {
    try {
      final success = await _repository.markAsAccessed(event.informationId);
      if (success) {
        emit(MarkedAsAccessedState(event.informationId));
        logInfo('Marked information as accessed: ${event.informationId}');
      } else {
        emit(CrudErrorState('Information item not found: ${event.informationId}'));
      }
    } catch (e, stackTrace) {
      logError('Failed to mark information as accessed: ${event.informationId}', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to mark as accessed: ${e.toString()}', exception: exception));
    }
  }

  /// Handle getting count of information items
  Future<void> _onGetCount(GetCountEvent event, Emitter<CrudState> emit) async {
    try {
      final count = await _repository.getCount(
        type: event.type,
        isFavorite: event.isFavorite,
        isArchived: event.isArchived,
      );
      emit(InformationCountState(
        count,
        type: event.type,
        isFavorite: event.isFavorite,
        isArchived: event.isArchived,
      ));
      logInfo('Information count retrieved: $count');
    } catch (e, stackTrace) {
      logError('Failed to get information count', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to get count: ${e.toString()}', exception: exception));
    }
  }

  /// Handle loading information items by tag IDs
  Future<void> _onLoadByTagIds(LoadByTagIdsEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final informationItems = await _repository.getByTagIds(
        event.tagIds,
        requireAllTags: event.requireAllTags,
        limit: event.limit,
        offset: event.offset,
      );
      emit(InformationLoadedByTagIdsState(
        informationItems,
        event.tagIds,
        event.requireAllTags,
      ));
      logInfo('Loaded ${informationItems.length} information items by tag IDs '
               '(${event.requireAllTags ? "all" : "any"} of ${event.tagIds.length} tags)');
    } catch (e, stackTrace) {
      logError('Failed to load information by tag IDs', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to load information by tags: ${e.toString()}', exception: exception));
    }
  }

  // ============================================================================
  // Tag Management Event Handlers
  // ============================================================================

  /// Handle adding tags to an information item
  Future<void> _onAddTags(AddTagsEvent event, Emitter<CrudState> emit) async {
    emit(TagOperationInProgressState(event.informationId, 'adding'));
    try {
      await _repository.addTags(event.informationId, event.tagIds);
      emit(TagsAddedState(event.informationId, event.tagIds));
      logInfo('Added ${event.tagIds.length} tags to information: ${event.informationId}');
    } catch (e, stackTrace) {
      logError('Failed to add tags to information: ${event.informationId}', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to add tags: ${e.toString()}', exception: exception));
    }
  }

  /// Handle removing tags from an information item
  Future<void> _onRemoveTags(RemoveTagsEvent event, Emitter<CrudState> emit) async {
    emit(TagOperationInProgressState(event.informationId, 'removing'));
    try {
      await _repository.removeTags(event.informationId, event.tagIds);
      emit(TagsRemovedState(event.informationId, event.tagIds));
      logInfo('Removed ${event.tagIds.length} tags from information: ${event.informationId}');
    } catch (e, stackTrace) {
      logError('Failed to remove tags from information: ${event.informationId}', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to remove tags: ${e.toString()}', exception: exception));
    }
  }

  /// Handle updating all tags for an information item
  Future<void> _onUpdateTags(UpdateTagsEvent event, Emitter<CrudState> emit) async {
    emit(TagOperationInProgressState(event.informationId, 'updating'));
    try {
      await _repository.updateTags(event.informationId, event.tagIds);
      emit(TagsUpdatedState(event.informationId, event.tagIds));
      logInfo('Updated tags for information: ${event.informationId} (${event.tagIds.length} tags)');
    } catch (e, stackTrace) {
      logError('Failed to update tags for information: ${event.informationId}', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to update tags: ${e.toString()}', exception: exception));
    }
  }

  /// Handle loading tag assignments for an information item
  Future<void> _onLoadTagAssignments(LoadTagAssignmentsEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final assignments = await _repository.getTagAssignments(event.informationId);
      emit(TagAssignmentsLoadedState(event.informationId, assignments));
      logInfo('Loaded ${assignments.length} tag assignments for information: ${event.informationId}');
    } catch (e, stackTrace) {
      logError('Failed to load tag assignments for information: ${event.informationId}', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to load tag assignments: ${e.toString()}', exception: exception));
    }
  }

  /// Handle loading tag IDs for an information item
  Future<void> _onLoadTagIds(LoadTagIdsEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final tagIds = await _repository.getTagIds(event.informationId);
      emit(TagIdsLoadedState(event.informationId, tagIds));
      logInfo('Loaded ${tagIds.length} tag IDs for information: ${event.informationId}');
    } catch (e, stackTrace) {
      logError('Failed to load tag IDs for information: ${event.informationId}', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to load tag IDs: ${e.toString()}', exception: exception));
    }
  }

  // ============================================================================
  // Convenience Methods for Common Operations
  // ============================================================================

  /// Load all information items (convenience method)
  void loadAll() {
    add(const LoadAllEvent());
  }

  /// Load information item by ID (convenience method)
  void loadById(String id) {
    add(LoadByIdEvent(id));
  }

  /// Create new information item (convenience method)
  void create(Information information) {
    add(CreateItemEvent<Information>(information));
  }

  /// Update information item (convenience method)
  void update(Information information) {
    add(UpdateItemEvent<Information>(information));
  }

  /// Delete information item (convenience method)
  void delete(String id) {
    add(DeleteItemEvent(id));
  }

  /// Search information items (convenience method)
  void search(String query) {
    add(SearchEvent(query));
  }

  /// Filter information items (convenience method)
  void filter(dynamic filterCriteria) {
    add(FilterEvent(filterCriteria));
  }

  /// Load information by type (convenience method)
  void loadByType(InformationType type, {int? limit, int? offset}) {
    add(LoadByTypeEvent(type, limit: limit, offset: offset));
  }

  /// Load favorites (convenience method)
  void loadFavorites({int? limit, int? offset}) {
    add(LoadFavoritesEvent(limit: limit, offset: offset));
  }

  /// Load archived items (convenience method)
  void loadArchived({int? limit, int? offset}) {
    add(LoadArchivedEvent(limit: limit, offset: offset));
  }

  /// Load recently accessed items (convenience method)
  void loadRecentlyAccessed({int limit = 10}) {
    add(LoadRecentlyAccessedEvent(limit: limit));
  }

  /// Load by importance (convenience method)
  void loadByImportance(int minImportance, {int? maxImportance, int? limit, int? offset}) {
    add(LoadByImportanceEvent(
      minImportance,
      maxImportance: maxImportance,
      limit: limit,
      offset: offset,
    ));
  }

  /// Mark as accessed (convenience method)
  void markAsAccessed(String informationId) {
    add(MarkAsAccessedEvent(informationId));
  }

  /// Get count (convenience method)
  void getCount({InformationType? type, bool? isFavorite, bool? isArchived}) {
    add(GetCountEvent(type: type, isFavorite: isFavorite, isArchived: isArchived));
  }

  /// Load by tag IDs (convenience method)
  void loadByTagIds(List<String> tagIds, {bool requireAllTags = false, int? limit, int? offset}) {
    add(LoadByTagIdsEvent(
      tagIds,
      requireAllTags: requireAllTags,
      limit: limit,
      offset: offset,
    ));
  }

  /// Add tags (convenience method)
  void addTags(String informationId, List<String> tagIds) {
    add(AddTagsEvent(informationId, tagIds));
  }

  /// Remove tags (convenience method)
  void removeTags(String informationId, List<String> tagIds) {
    add(RemoveTagsEvent(informationId, tagIds));
  }

  /// Update tags (convenience method)
  void updateTags(String informationId, List<String> tagIds) {
    add(UpdateTagsEvent(informationId, tagIds));
  }

  /// Load tag assignments (convenience method)
  void loadTagAssignments(String informationId) {
    add(LoadTagAssignmentsEvent(informationId));
  }

  /// Load tag IDs (convenience method)
  void loadTagIds(String informationId) {
    add(LoadTagIdsEvent(informationId));
  }
}