import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/information/information_event.dart';
import 'package:mind_house_app/blocs/information/information_state.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/services/information_service.dart';
import 'package:mind_house_app/services/tag_service.dart';

class InformationBloc extends Bloc<InformationEvent, InformationState> {
  final InformationRepository _informationRepository;
  final TagRepository _tagRepository;
  final InformationService _informationService;
  final TagService _tagService;

  InformationBloc({
    required InformationRepository informationRepository,
    required TagRepository tagRepository,
    required InformationService informationService,
    required TagService tagService,
  })  : _informationRepository = informationRepository,
        _tagRepository = tagRepository,
        _informationService = informationService,
        _tagService = tagService,
        super(InformationInitial()) {
    on<LoadAllInformation>(_onLoadAllInformation);
    on<CreateInformation>(_onCreateInformation);
    on<UpdateInformation>(_onUpdateInformation);
    on<DeleteInformation>(_onDeleteInformation);
    on<SearchInformation>(_onSearchInformation);
    on<FilterInformationByTags>(_onFilterInformationByTags);
    on<LoadInformationById>(_onLoadInformationById);
  }

  Future<void> _onLoadAllInformation(
    LoadAllInformation event,
    Emitter<InformationState> emit,
  ) async {
    emit(InformationLoading());
    try {
      final information = await _informationRepository.getAll();
      emit(InformationLoaded(information));
    } catch (e) {
      emit(InformationError('Failed to load information: $e'));
    }
  }

  Future<void> _onCreateInformation(
    CreateInformation event,
    Emitter<InformationState> emit,
  ) async {
    if (event.content.trim().isEmpty) {
      emit(InformationError('Content cannot be empty'));
      return;
    }

    emit(InformationLoading());
    try {
      // Use the service for business logic
      final createdInfo = await _informationService.createInformation(
        content: event.content,
        tagNames: event.tagNames,
      );
      
      emit(InformationCreated(createdInfo));
      
      // Reload all information to update the list
      add(LoadAllInformation());
    } catch (e) {
      emit(InformationError('Failed to create information: $e'));
    }
  }

  Future<void> _onUpdateInformation(
    UpdateInformation event,
    Emitter<InformationState> emit,
  ) async {
    if (event.information.content.trim().isEmpty) {
      emit(InformationError('Content cannot be empty'));
      return;
    }

    emit(InformationLoading());
    try {
      // Use the service for business logic
      final updatedInfo = await _informationService.updateInformation(
        information: event.information,
        tagNames: event.tagNames,
      );
      
      emit(InformationUpdated(updatedInfo));
      
      // Reload to reflect changes
      add(LoadAllInformation());
    } catch (e) {
      emit(InformationError('Failed to update information: $e'));
    }
  }

  Future<void> _onDeleteInformation(
    DeleteInformation event,
    Emitter<InformationState> emit,
  ) async {
    emit(InformationLoading());
    try {
      // Use the service for business logic
      await _informationService.deleteInformation(event.informationId);
      emit(InformationDeleted(event.informationId));
      
      // Reload to reflect deletion
      add(LoadAllInformation());
    } catch (e) {
      emit(InformationError('Failed to delete information: $e'));
    }
  }

  Future<void> _onSearchInformation(
    SearchInformation event,
    Emitter<InformationState> emit,
  ) async {
    final query = event.query.trim();
    
    // If empty query, load all information
    if (query.isEmpty) {
      add(LoadAllInformation());
      return;
    }

    emit(InformationLoading());
    try {
      // Use the service for advanced search
      final information = await _informationService.searchInformation(
        query: query,
      );
      emit(InformationLoaded(information));
    } catch (e) {
      emit(InformationError('Failed to search information: $e'));
    }
  }

  Future<void> _onFilterInformationByTags(
    FilterInformationByTags event,
    Emitter<InformationState> emit,
  ) async {
    emit(InformationLoading());
    try {
      // This would require implementing tag filtering in repository
      // For now, just load all information
      final information = await _informationRepository.getAll();
      emit(InformationLoaded(information));
    } catch (e) {
      emit(InformationError('Failed to filter information: $e'));
    }
  }

  Future<void> _handleTags(List<String> tagNames, String informationId) async {
    for (final tagName in tagNames) {
      // Find or create tag
      var tag = await _tagRepository.findByName(tagName);
      if (tag == null) {
        tag = await _tagRepository.create(
          Tag(name: tagName),
        );
      }
      
      // Increment usage count
      await _tagRepository.incrementUsageCount(tag.id!);
      
      // Create association (would need InformationTagRepository)
      // await _informationTagRepository.create(InformationTag(
      //   informationId: informationId,
      //   tagId: tag.id!,
      // ));
    }
  }

  Future<void> _onLoadInformationById(
    LoadInformationById event,
    Emitter<InformationState> emit,
  ) async {
    emit(InformationLoading());
    try {
      final information = await _informationRepository.getById(event.informationId);
      if (information != null) {
        emit(InformationSingleLoaded(information));
      } else {
        emit(InformationError('Information not found'));
      }
    } catch (e) {
      emit(InformationError('Failed to load information: $e'));
    }
  }
}