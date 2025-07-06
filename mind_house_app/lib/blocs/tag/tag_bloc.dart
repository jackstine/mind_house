import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/tag/tag_event.dart';
import 'package:mind_house_app/blocs/tag/tag_state.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';

class TagBloc extends Bloc<TagEvent, TagState> {
  final TagRepository _tagRepository;

  TagBloc({
    required TagRepository tagRepository,
  })  : _tagRepository = tagRepository,
        super(TagInitial()) {
    on<LoadAllTags>(_onLoadAllTags);
    on<CreateTag>(_onCreateTag);
    on<UpdateTag>(_onUpdateTag);
    on<DeleteTag>(_onDeleteTag);
    on<GetTagSuggestions>(_onGetTagSuggestions);
    on<SearchTags>(_onSearchTags);
    on<LoadMostUsedTags>(_onLoadMostUsedTags);
    on<IncrementTagUsage>(_onIncrementTagUsage);
  }

  Future<void> _onLoadAllTags(
    LoadAllTags event,
    Emitter<TagState> emit,
  ) async {
    emit(TagLoading());
    try {
      final tags = await _tagRepository.getAll();
      emit(TagLoaded(tags));
    } catch (e) {
      emit(TagError('Failed to load tags: $e'));
    }
  }

  Future<void> _onCreateTag(
    CreateTag event,
    Emitter<TagState> emit,
  ) async {
    final tagName = event.name.trim();
    
    if (tagName.isEmpty) {
      emit(TagError('Tag name cannot be empty'));
      return;
    }

    emit(TagLoading());
    try {
      // Check if tag already exists
      final existingTag = await _tagRepository.findByName(tagName);
      if (existingTag != null) {
        emit(TagError('Tag "$tagName" already exists'));
        return;
      }

      final tag = Tag(
        name: tagName,
        color: event.color,
      );
      final createdTag = await _tagRepository.create(tag);
      emit(TagCreated(createdTag));
      
      // Reload all tags to update the list
      add(LoadAllTags());
    } catch (e) {
      emit(TagError('Failed to create tag: $e'));
    }
  }

  Future<void> _onUpdateTag(
    UpdateTag event,
    Emitter<TagState> emit,
  ) async {
    emit(TagLoading());
    try {
      final updatedTag = await _tagRepository.update(event.tag);
      emit(TagUpdated(updatedTag));
    } catch (e) {
      emit(TagError('Failed to update tag: $e'));
    }
  }

  Future<void> _onDeleteTag(
    DeleteTag event,
    Emitter<TagState> emit,
  ) async {
    emit(TagLoading());
    try {
      // Check if tag exists before deletion
      final existingTag = await _tagRepository.getById(event.tagId);
      if (existingTag == null) {
        emit(TagError('Tag not found'));
        return;
      }

      await _tagRepository.delete(event.tagId);
      emit(TagDeleted(event.tagId));
      
      // Reload to reflect deletion
      add(LoadAllTags());
    } catch (e) {
      emit(TagError('Failed to delete tag: $e'));
    }
  }

  Future<void> _onGetTagSuggestions(
    GetTagSuggestions event,
    Emitter<TagState> emit,
  ) async {
    try {
      final suggestions = await _tagRepository.getSuggestions(
        event.prefix,
        limit: event.limit,
      );
      emit(TagSuggestions(suggestions));
    } catch (e) {
      emit(TagError('Failed to get tag suggestions: $e'));
    }
  }

  Future<void> _onSearchTags(
    SearchTags event,
    Emitter<TagState> emit,
  ) async {
    emit(TagLoading());
    try {
      final tags = await _tagRepository.searchByName(event.query);
      emit(TagLoaded(tags));
    } catch (e) {
      emit(TagError('Failed to search tags: $e'));
    }
  }

  Future<void> _onLoadMostUsedTags(
    LoadMostUsedTags event,
    Emitter<TagState> emit,
  ) async {
    emit(TagLoading());
    try {
      final tags = await _tagRepository.getMostUsed(limit: event.limit);
      emit(TagLoaded(tags));
    } catch (e) {
      emit(TagError('Failed to load most used tags: $e'));
    }
  }

  Future<void> _onIncrementTagUsage(
    IncrementTagUsage event,
    Emitter<TagState> emit,
  ) async {
    try {
      // Check if tag exists
      final existingTag = await _tagRepository.getById(event.tagId);
      if (existingTag == null) {
        emit(TagError('Tag not found'));
        return;
      }

      await _tagRepository.incrementUsageCount(event.tagId);
      emit(TagUsageIncremented(event.tagId));
    } catch (e) {
      emit(TagError('Failed to increment tag usage: $e'));
    }
  }
}