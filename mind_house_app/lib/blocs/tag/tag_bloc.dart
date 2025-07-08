import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/repositories/interfaces/tag_repository_interface.dart';
import 'package:mind_house_app/utils/tag_normalization.dart';
import 'package:mind_house_app/blocs/base/base_event.dart';
import 'package:mind_house_app/blocs/base/base_state.dart';
import 'tag_events.dart';
import 'tag_states.dart';

/// TagBloc - Business Logic Component for Tag Management
/// 
/// This BLoC manages all tag-related operations in the Mind House application,
/// including CRUD operations, search, suggestions, analytics, and usage tracking.
/// 
/// Features:
/// - Complete CRUD operations for tags
/// - Advanced search and filtering
/// - Smart tag suggestions with multiple algorithms
/// - Usage tracking and analytics
/// - Bulk operations for performance
/// - Comprehensive error handling
/// - Repository pattern for testability
/// 
/// The TagBloc follows BLoC patterns and provides a clean separation between
/// UI and business logic, making it easy to test and maintain.
class TagBloc extends Bloc<BaseEvent, BaseState> {
  final ITagRepository _tagRepository;
  
  // Cache for performance optimization
  final Map<String, Tag> _tagCache = {};
  final Map<String, List<Tag>> _listCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  TagBloc({ITagRepository? tagRepository})
      : _tagRepository = tagRepository ?? TagRepository(),
        super(const TagInitialState()) {
    
    // Register event handlers
    on<LoadAllTagsEvent>(_onLoadAllTags);
    on<LoadTagByIdEvent>(_onLoadTagById);
    on<LoadTagByNameEvent>(_onLoadTagByName);
    on<LoadSortedTagsEvent>(_onLoadSortedTags);
    
    // Search event handlers
    on<SearchTagsEvent>(_onSearchTags);
    on<GetTagSuggestionsEvent>(_onGetTagSuggestions);
    on<GetSmartTagSuggestionsEvent>(_onGetSmartTagSuggestions);
    on<GetContextualSuggestionsEvent>(_onGetContextualSuggestions);
    on<GetTrendingSuggestionsEvent>(_onGetTrendingSuggestions);
    on<GetDiverseSuggestionsEvent>(_onGetDiverseSuggestions);
    
    // Filter event handlers
    on<LoadTagsByColorEvent>(_onLoadTagsByColor);
    on<LoadFrequentlyUsedTagsEvent>(_onLoadFrequentlyUsedTags);
    on<LoadUnusedTagsEvent>(_onLoadUnusedTags);
    on<LoadRecentlyUsedTagsEvent>(_onLoadRecentlyUsedTags);
    
    // CRUD event handlers
    on<CreateTagEvent>(_onCreateTag);
    on<CreateTagFromInputEvent>(_onCreateTagFromInput);
    on<UpdateTagEvent>(_onUpdateTag);
    on<DeleteTagEvent>(_onDeleteTag);
    
    // Usage event handlers
    on<IncrementTagUsageEvent>(_onIncrementTagUsage);
    on<UpdateTagLastUsedEvent>(_onUpdateTagLastUsed);
    
    // Bulk operations event handlers
    on<BulkCreateTagsEvent>(_onBulkCreateTags);
    on<BulkIncrementUsageEvent>(_onBulkIncrementUsage);
    
    // Analytics event handlers
    on<LoadTagCountEvent>(_onLoadTagCount);
    on<LoadUsedColorsEvent>(_onLoadUsedColors);
    
    // Utility event handlers
    on<RefreshTagsEvent>(_onRefreshTags);
    on<ClearTagCacheEvent>(_onClearTagCache);
    on<ValidateTagEvent>(_onValidateTag);
    on<LoadTagAnalyticsEvent>(_onLoadTagAnalytics);
  }

  /// Check if cache is valid
  bool get _isCacheValid {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiry;
  }

  /// Update cache timestamp
  void _updateCacheTimestamp() {
    _lastCacheUpdate = DateTime.now();
  }

  /// Clear all caches
  void _clearAllCaches() {
    _tagCache.clear();
    _listCache.clear();
    _lastCacheUpdate = null;
  }

  // Load Events
  Future<void> _onLoadAllTags(LoadAllTagsEvent event, Emitter<BaseState> emit) async {
    emit(const TagLoadingState());
    
    try {
      final cacheKey = 'all_${event.limit}_${event.offset}';
      
      // Check cache first
      if (_isCacheValid && _listCache.containsKey(cacheKey)) {
        emit(TagsLoadedState(_listCache[cacheKey]!));
        return;
      }
      
      final tags = await _tagRepository.getAll(limit: event.limit, offset: event.offset);
      
      // Update cache
      _listCache[cacheKey] = tags;
      for (final tag in tags) {
        _tagCache[tag.id] = tag;
      }
      _updateCacheTimestamp();
      
      emit(TagsLoadedState(tags));
    } catch (e) {
      emit(TagErrorState('Failed to load tags: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onLoadTagById(LoadTagByIdEvent event, Emitter<BaseState> emit) async {
    emit(const TagLoadingState());
    
    try {
      // Check cache first
      if (_isCacheValid && _tagCache.containsKey(event.id)) {
        emit(TagLoadedState(_tagCache[event.id]!));
        return;
      }
      
      final tag = await _tagRepository.getById(event.id);
      
      if (tag != null) {
        // Update cache
        _tagCache[tag.id] = tag;
        _updateCacheTimestamp();
        
        emit(TagLoadedState(tag));
      } else {
        emit(TagErrorState('Tag not found with ID: ${event.id}'));
      }
    } catch (e) {
      emit(TagErrorState('Failed to load tag by ID: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onLoadTagByName(LoadTagByNameEvent event, Emitter<BaseState> emit) async {
    emit(const TagLoadingState());
    
    try {
      final tag = await _tagRepository.getByName(event.name);
      
      if (tag != null) {
        // Update cache
        _tagCache[tag.id] = tag;
        _updateCacheTimestamp();
        
        emit(TagLoadedState(tag));
      } else {
        emit(TagErrorState('Tag not found with name: ${event.name}'));
      }
    } catch (e) {
      emit(TagErrorState('Failed to load tag by name: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onLoadSortedTags(LoadSortedTagsEvent event, Emitter<BaseState> emit) async {
    emit(const TagLoadingState());
    
    try {
      final cacheKey = 'sorted_${event.sortBy.name}_${event.sortOrder.name}_${event.limit}_${event.offset}';
      
      // Check cache first
      if (_isCacheValid && _listCache.containsKey(cacheKey)) {
        emit(TagsLoadedState(_listCache[cacheKey]!));
        return;
      }
      
      final tags = await _tagRepository.getAllSorted(
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
        limit: event.limit,
        offset: event.offset,
      );
      
      // Update cache
      _listCache[cacheKey] = tags;
      for (final tag in tags) {
        _tagCache[tag.id] = tag;
      }
      _updateCacheTimestamp();
      
      emit(TagsLoadedState(tags));
    } catch (e) {
      emit(TagErrorState('Failed to load sorted tags: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  // Search Events
  Future<void> _onSearchTags(SearchTagsEvent event, Emitter<BaseState> emit) async {
    emit(const TagSearchingState());
    
    try {
      if (event.query.trim().isEmpty) {
        emit(const TagsLoadedState([]));
        return;
      }
      
      final tags = await _tagRepository.searchByName(
        event.query,
        limit: event.limit,
        offset: event.offset,
      );
      
      emit(TagsLoadedState(tags));
    } catch (e) {
      emit(TagSearchErrorState('Failed to search tags: ${e.toString()}', event.query, exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onGetTagSuggestions(GetTagSuggestionsEvent event, Emitter<BaseState> emit) async {
    emit(const TagSuggestionsLoadingState());
    
    try {
      if (event.partialName.trim().isEmpty) {
        emit(const TagSuggestionsLoadedState([], query: ''));
        return;
      }
      
      final suggestions = await _tagRepository.getSuggestions(
        event.partialName,
        limit: event.limit,
      );
      
      emit(TagSuggestionsLoadedState(suggestions, query: event.partialName));
    } catch (e) {
      emit(TagSuggestionsErrorState('Failed to get tag suggestions: ${e.toString()}', event.partialName, exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onGetSmartTagSuggestions(GetSmartTagSuggestionsEvent event, Emitter<BaseState> emit) async {
    emit(const TagSuggestionsLoadingState());
    
    try {
      if (event.partialName.trim().isEmpty) {
        emit(const TagSuggestionsLoadedState([], query: ''));
        return;
      }
      
      final suggestions = await _tagRepository.getSmartSuggestions(
        event.partialName,
        existingTagIds: event.existingTagIds,
        limit: event.limit,
        includeRecentlyUsed: event.includeRecentlyUsed,
      );
      
      emit(TagSuggestionsLoadedState(suggestions, query: event.partialName));
    } catch (e) {
      emit(TagSuggestionsErrorState('Failed to get smart tag suggestions: ${e.toString()}', event.partialName, exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onGetContextualSuggestions(GetContextualSuggestionsEvent event, Emitter<BaseState> emit) async {
    emit(const TagSuggestionsLoadingState());
    
    try {
      if (event.baseTagIds.isEmpty) {
        emit(const TagSuggestionsLoadedState([], query: ''));
        return;
      }
      
      final suggestions = await _tagRepository.getContextualSuggestions(
        event.baseTagIds,
        limit: event.limit,
      );
      
      emit(TagSuggestionsLoadedState(suggestions, query: 'contextual'));
    } catch (e) {
      emit(TagSuggestionsErrorState('Failed to get contextual suggestions: ${e.toString()}', 'contextual', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onGetTrendingSuggestions(GetTrendingSuggestionsEvent event, Emitter<BaseState> emit) async {
    emit(const TagSuggestionsLoadingState());
    
    try {
      final suggestions = await _tagRepository.getTrendingSuggestions(
        days: event.days,
        limit: event.limit,
      );
      
      emit(TagSuggestionsLoadedState(suggestions, query: 'trending'));
    } catch (e) {
      emit(TagSuggestionsErrorState('Failed to get trending suggestions: ${e.toString()}', 'trending', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onGetDiverseSuggestions(GetDiverseSuggestionsEvent event, Emitter<BaseState> emit) async {
    emit(const TagSuggestionsLoadingState());
    
    try {
      final suggestions = await _tagRepository.getDiverseSuggestions(
        excludeTagIds: event.excludeTagIds,
        limit: event.limit,
        maxPerColor: event.maxPerColor,
      );
      
      emit(TagSuggestionsLoadedState(suggestions, query: 'diverse'));
    } catch (e) {
      emit(TagSuggestionsErrorState('Failed to get diverse suggestions: ${e.toString()}', 'diverse', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  // Filter Events
  Future<void> _onLoadTagsByColor(LoadTagsByColorEvent event, Emitter<BaseState> emit) async {
    emit(const TagLoadingState());
    
    try {
      final cacheKey = 'color_${event.color}_${event.limit}_${event.offset}';
      
      // Check cache first
      if (_isCacheValid && _listCache.containsKey(cacheKey)) {
        emit(TagsLoadedState(_listCache[cacheKey]!));
        return;
      }
      
      final tags = await _tagRepository.getByColor(
        event.color,
        limit: event.limit,
        offset: event.offset,
      );
      
      // Update cache
      _listCache[cacheKey] = tags;
      for (final tag in tags) {
        _tagCache[tag.id] = tag;
      }
      _updateCacheTimestamp();
      
      emit(TagsLoadedState(tags));
    } catch (e) {
      emit(TagErrorState('Failed to load tags by color: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onLoadFrequentlyUsedTags(LoadFrequentlyUsedTagsEvent event, Emitter<BaseState> emit) async {
    emit(const TagLoadingState());
    
    try {
      final cacheKey = 'frequent_${event.threshold}_${event.limit}';
      
      // Check cache first
      if (_isCacheValid && _listCache.containsKey(cacheKey)) {
        emit(TagsLoadedState(_listCache[cacheKey]!));
        return;
      }
      
      final tags = await _tagRepository.getFrequentlyUsed(
        threshold: event.threshold,
        limit: event.limit,
      );
      
      // Update cache
      _listCache[cacheKey] = tags;
      for (final tag in tags) {
        _tagCache[tag.id] = tag;
      }
      _updateCacheTimestamp();
      
      emit(TagsLoadedState(tags));
    } catch (e) {
      emit(TagErrorState('Failed to load frequently used tags: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onLoadUnusedTags(LoadUnusedTagsEvent event, Emitter<BaseState> emit) async {
    emit(const TagLoadingState());
    
    try {
      final cacheKey = 'unused_${event.limit}';
      
      // Check cache first
      if (_isCacheValid && _listCache.containsKey(cacheKey)) {
        emit(TagsLoadedState(_listCache[cacheKey]!));
        return;
      }
      
      final tags = await _tagRepository.getUnused(limit: event.limit);
      
      // Update cache
      _listCache[cacheKey] = tags;
      for (final tag in tags) {
        _tagCache[tag.id] = tag;
      }
      _updateCacheTimestamp();
      
      emit(TagsLoadedState(tags));
    } catch (e) {
      emit(TagErrorState('Failed to load unused tags: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onLoadRecentlyUsedTags(LoadRecentlyUsedTagsEvent event, Emitter<BaseState> emit) async {
    emit(const TagLoadingState());
    
    try {
      final cacheKey = 'recent_${event.days}_${event.limit}';
      
      // Check cache first
      if (_isCacheValid && _listCache.containsKey(cacheKey)) {
        emit(TagsLoadedState(_listCache[cacheKey]!));
        return;
      }
      
      final tags = await _tagRepository.getRecentlyUsed(
        days: event.days,
        limit: event.limit,
      );
      
      // Update cache
      _listCache[cacheKey] = tags;
      for (final tag in tags) {
        _tagCache[tag.id] = tag;
      }
      _updateCacheTimestamp();
      
      emit(TagsLoadedState(tags));
    } catch (e) {
      emit(TagErrorState('Failed to load recently used tags: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  // CRUD Events
  Future<void> _onCreateTag(CreateTagEvent event, Emitter<BaseState> emit) async {
    emit(const TagCreatingState());
    
    try {
      // Check if tag with same name already exists
      final existingTag = await _tagRepository.getByName(event.tag.name);
      if (existingTag != null) {
        emit(TagCreationErrorState('Tag with name "${event.tag.name}" already exists', failedTag: event.tag));
        return;
      }
      
      final tagId = await _tagRepository.create(event.tag);
      final createdTag = await _tagRepository.getById(tagId);
      
      if (createdTag != null) {
        // Update cache
        _tagCache[createdTag.id] = createdTag;
        _clearAllCaches(); // Clear list caches to force refresh
        
        emit(TagCreatedState(createdTag));
      } else {
        emit(TagCreationErrorState('Failed to retrieve created tag', failedTag: event.tag));
      }
    } catch (e) {
      emit(TagCreationErrorState('Failed to create tag: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString()), failedTag: event.tag));
    }
  }

  Future<void> _onCreateTagFromInput(CreateTagFromInputEvent event, Emitter<BaseState> emit) async {
    emit(const TagCreatingState());
    
    try {
      // Validate input first
      if (!TagNormalization.isValid(event.input)) {
        emit(TagValidationErrorState('Invalid tag name: "${event.input}"', event.input));
        return;
      }
      
      // Check if tag with same name already exists
      final normalizedName = TagNormalization.normalizeName(event.input);
      final existingTag = await _tagRepository.getByName(normalizedName);
      if (existingTag != null) {
        emit(TagCreationErrorState('Tag with name "$normalizedName" already exists'));
        return;
      }
      
      final tag = Tag.fromInput(event.input, color: event.color);
      final tagId = await _tagRepository.create(tag);
      final createdTag = await _tagRepository.getById(tagId);
      
      if (createdTag != null) {
        // Update cache
        _tagCache[createdTag.id] = createdTag;
        _clearAllCaches(); // Clear list caches to force refresh
        
        emit(TagCreatedState(createdTag));
      } else {
        emit(TagCreationErrorState('Failed to retrieve created tag'));
      }
    } catch (e) {
      emit(TagCreationErrorState('Failed to create tag from input: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onUpdateTag(UpdateTagEvent event, Emitter<BaseState> emit) async {
    emit(const TagUpdatingState());
    
    try {
      final success = await _tagRepository.update(event.tag);
      
      if (success) {
        // Update cache
        _tagCache[event.tag.id] = event.tag;
        _clearAllCaches(); // Clear list caches to force refresh
        
        emit(TagUpdatedState(event.tag));
      } else {
        emit(TagUpdateErrorState('Failed to update tag - no rows affected', failedTag: event.tag));
      }
    } catch (e) {
      emit(TagUpdateErrorState('Failed to update tag: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString()), failedTag: event.tag));
    }
  }

  Future<void> _onDeleteTag(DeleteTagEvent event, Emitter<BaseState> emit) async {
    emit(const TagDeletingState());
    
    try {
      final success = await _tagRepository.delete(event.id);
      
      if (success) {
        // Remove from cache
        _tagCache.remove(event.id);
        _clearAllCaches(); // Clear list caches to force refresh
        
        emit(TagDeletedState(event.id));
      } else {
        emit(TagDeletionErrorState('Failed to delete tag - no rows affected', event.id));
      }
    } catch (e) {
      emit(TagDeletionErrorState('Failed to delete tag: ${e.toString()}', event.id, exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  // Usage Events
  Future<void> _onIncrementTagUsage(IncrementTagUsageEvent event, Emitter<BaseState> emit) async {
    emit(const TagUsageUpdatingState());
    
    try {
      final success = await _tagRepository.incrementUsage(event.id);
      
      if (success) {
        // Update cache if tag exists
        if (_tagCache.containsKey(event.id)) {
          final updatedTag = _tagCache[event.id]!.incrementUsage();
          _tagCache[event.id] = updatedTag;
        }
        _clearAllCaches(); // Clear list caches to force refresh
        
        // Get updated usage count
        final tag = await _tagRepository.getById(event.id);
        if (tag != null) {
          emit(TagUsageUpdatedState(event.id, tag.usageCount));
        } else {
          emit(TagUsageUpdatedState(event.id, 0));
        }
      } else {
        emit(TagErrorState('Failed to increment tag usage - tag not found'));
      }
    } catch (e) {
      emit(TagErrorState('Failed to increment tag usage: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onUpdateTagLastUsed(UpdateTagLastUsedEvent event, Emitter<BaseState> emit) async {
    emit(const TagUsageUpdatingState());
    
    try {
      final success = await _tagRepository.updateLastUsed(event.id);
      
      if (success) {
        // Update cache if tag exists
        if (_tagCache.containsKey(event.id)) {
          final updatedTag = _tagCache[event.id]!.copyWith(updatedAt: DateTime.now());
          _tagCache[event.id] = updatedTag;
        }
        _clearAllCaches(); // Clear list caches to force refresh
        
        emit(TagUsageUpdatedState(event.id, _tagCache[event.id]?.usageCount ?? 0));
      } else {
        emit(TagErrorState('Failed to update tag last used - tag not found'));
      }
    } catch (e) {
      emit(TagErrorState('Failed to update tag last used: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  // Bulk Operations
  Future<void> _onBulkCreateTags(BulkCreateTagsEvent event, Emitter<BaseState> emit) async {
    emit(TagBulkCreatingState(event.tags.length));
    
    try {
      final List<Tag> createdTags = [];
      
      for (final tag in event.tags) {
        try {
          // Check if tag already exists
          final existingTag = await _tagRepository.getByName(tag.name);
          if (existingTag == null) {
            final tagId = await _tagRepository.create(tag);
            final createdTag = await _tagRepository.getById(tagId);
            if (createdTag != null) {
              createdTags.add(createdTag);
              _tagCache[createdTag.id] = createdTag;
            }
          }
        } catch (e) {
          // Continue with other tags if one fails
          continue;
        }
      }
      
      _clearAllCaches(); // Clear list caches to force refresh
      emit(TagBulkCreatedState(createdTags));
    } catch (e) {
      emit(TagErrorState('Failed to bulk create tags: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onBulkIncrementUsage(BulkIncrementUsageEvent event, Emitter<BaseState> emit) async {
    emit(const TagUsageUpdatingState());
    
    try {
      final List<String> successfulIds = [];
      
      for (final tagId in event.tagIds) {
        try {
          final success = await _tagRepository.incrementUsage(tagId);
          if (success) {
            successfulIds.add(tagId);
            
            // Update cache if tag exists
            if (_tagCache.containsKey(tagId)) {
              final updatedTag = _tagCache[tagId]!.incrementUsage();
              _tagCache[tagId] = updatedTag;
            }
          }
        } catch (e) {
          // Continue with other tags if one fails
          continue;
        }
      }
      
      _clearAllCaches(); // Clear list caches to force refresh
      emit(TagBulkUsageUpdatedState(successfulIds));
    } catch (e) {
      emit(TagErrorState('Failed to bulk increment usage: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  // Analytics Events
  Future<void> _onLoadTagCount(LoadTagCountEvent event, Emitter<BaseState> emit) async {
    emit(const TagAnalyticsLoadingState());
    
    try {
      final count = await _tagRepository.getCount(
        hasUsage: event.hasUsage,
        color: event.color,
        minUsageCount: event.minUsageCount,
      );
      
      emit(TagCountLoadedState(count));
    } catch (e) {
      emit(TagErrorState('Failed to load tag count: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onLoadUsedColors(LoadUsedColorsEvent event, Emitter<BaseState> emit) async {
    emit(const TagAnalyticsLoadingState());
    
    try {
      final colors = await _tagRepository.getUsedColors();
      emit(TagColorsLoadedState(colors));
    } catch (e) {
      emit(TagErrorState('Failed to load used colors: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  // Utility Events
  Future<void> _onRefreshTags(RefreshTagsEvent event, Emitter<BaseState> emit) async {
    _clearAllCaches();
    
    // Reload the current data based on current state
    if (state is TagsLoadedState) {
      add(const LoadAllTagsEvent());
    } else if (state is TagLoadedState) {
      // If we have a single tag loaded, we can't easily refresh without knowing the ID
      // Just clear the cache and emit the current state
      emit(state);
    } else {
      emit(const TagInitialState());
    }
  }

  Future<void> _onClearTagCache(ClearTagCacheEvent event, Emitter<BaseState> emit) async {
    _clearAllCaches();
    emit(const TagCacheClearedState());
  }

  Future<void> _onValidateTag(ValidateTagEvent event, Emitter<BaseState> emit) async {
    try {
      if (TagNormalization.isValid(event.name)) {
        final normalizedName = TagNormalization.normalizeName(event.name);
        emit(TagValidationSuccessState(normalizedName));
      } else {
        emit(TagValidationErrorState('Invalid tag name: "${event.name}"', event.name));
      }
    } catch (e) {
      emit(TagValidationErrorState('Tag validation failed: ${e.toString()}', event.name, exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  /// Load comprehensive tag analytics
  Future<void> _onLoadTagAnalytics(LoadTagAnalyticsEvent event, Emitter<BaseState> emit) async {
    emit(const TagAnalyticsLoadingState());
    
    try {
      // Load multiple analytics in parallel
      final futures = await Future.wait([
        _tagRepository.getCount(),
        _tagRepository.getCount(hasUsage: true),
        _tagRepository.getCount(hasUsage: false),
        _tagRepository.getFrequentlyUsed(limit: 10),
        _tagRepository.getRecentlyUsed(limit: 10),
        _tagRepository.getUsedColors(),
      ]);
      
      final totalTags = futures[0] as int;
      final usedTags = futures[1] as int;
      final unusedTags = futures[2] as int;
      final mostUsedTags = futures[3] as List<Tag>;
      final recentlyUsedTags = futures[4] as List<Tag>;
      final usedColors = futures[5] as List<String>;
      
      emit(TagAnalyticsLoadedState(
        totalTags: totalTags,
        usedTags: usedTags,
        unusedTags: unusedTags,
        mostUsedTags: mostUsedTags,
        recentlyUsedTags: recentlyUsedTags,
        usedColors: usedColors,
      ));
    } catch (e) {
      emit(TagErrorState('Failed to load tag analytics: ${e.toString()}', exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  @override
  Future<void> close() {
    _clearAllCaches();
    return super.close();
  }
}