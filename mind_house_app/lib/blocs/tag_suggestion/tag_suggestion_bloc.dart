import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/tag_suggestion/tag_suggestion_event.dart';
import 'package:mind_house_app/blocs/tag_suggestion/tag_suggestion_state.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/services/tag_service.dart';

class TagSuggestionBloc extends Bloc<TagSuggestionEvent, TagSuggestionState> {
  final TagRepository _tagRepository;
  final TagService _tagService;
  Timer? _debounceTimer;

  TagSuggestionBloc({
    required TagRepository tagRepository,
    required TagService tagService,
  })  : _tagRepository = tagRepository,
        _tagService = tagService,
        super(TagSuggestionInitial()) {
    on<LoadTagSuggestions>(_onLoadTagSuggestions);
    on<ClearTagSuggestions>(_onClearTagSuggestions);
    on<SelectTagSuggestion>(_onSelectTagSuggestion);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadTagSuggestions(
    LoadTagSuggestions event,
    Emitter<TagSuggestionState> emit,
  ) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // If query is empty, clear suggestions
    if (event.prefix.trim().isEmpty) {
      emit(TagSuggestionInitial());
      return;
    }

    // Debounce the search to avoid too many API calls
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      emit(TagSuggestionLoading());
      
      try {
        // Use smart suggestions from TagService
        final suggestions = await _tagService.getSmartSuggestions(
          event.prefix.trim(),
          limit: event.limit,
        );

        if (suggestions.isEmpty) {
          emit(TagSuggestionEmpty(event.prefix));
        } else {
          emit(TagSuggestionLoaded(
            suggestions: suggestions,
            query: event.prefix,
          ));
        }
      } catch (e) {
        emit(TagSuggestionError('Failed to load suggestions: $e'));
      }
    });
  }

  Future<void> _onClearTagSuggestions(
    ClearTagSuggestions event,
    Emitter<TagSuggestionState> emit,
  ) async {
    _debounceTimer?.cancel();
    emit(TagSuggestionInitial());
  }

  Future<void> _onSelectTagSuggestion(
    SelectTagSuggestion event,
    Emitter<TagSuggestionState> emit,
  ) async {
    emit(TagSuggestionSelected(event.tagName));
    // Optionally clear suggestions after selection
    add(ClearTagSuggestions());
  }
}