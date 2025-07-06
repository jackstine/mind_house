import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/information/information_event.dart';
import 'package:mind_house_app/blocs/information/information_state.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';

class InformationBloc extends Bloc<InformationEvent, InformationState> {
  final InformationRepository _informationRepository;
  final TagRepository _tagRepository;

  InformationBloc({
    required InformationRepository informationRepository,
    required TagRepository tagRepository,
  })  : _informationRepository = informationRepository,
        _tagRepository = tagRepository,
        super(InformationInitial()) {
    on<LoadAllInformation>(_onLoadAllInformation);
    on<CreateInformation>(_onCreateInformation);
    on<UpdateInformation>(_onUpdateInformation);
    on<DeleteInformation>(_onDeleteInformation);
    on<SearchInformation>(_onSearchInformation);
    on<FilterInformationByTags>(_onFilterInformationByTags);
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
    emit(InformationLoading());
    try {
      final information = Information(content: event.content);
      final createdInfo = await _informationRepository.create(information);
      
      // Handle tags
      await _handleTags(event.tagNames, createdInfo.id);
      
      emit(InformationCreated(createdInfo));
    } catch (e) {
      emit(InformationError('Failed to create information: $e'));
    }
  }

  Future<void> _onUpdateInformation(
    UpdateInformation event,
    Emitter<InformationState> emit,
  ) async {
    emit(InformationLoading());
    try {
      final updatedInfo = await _informationRepository.update(event.information);
      
      // Handle tags (this would require implementing tag association repository)
      await _handleTags(event.tagNames, updatedInfo.id);
      
      emit(InformationUpdated(updatedInfo));
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
      await _informationRepository.delete(event.informationId);
      emit(InformationDeleted(event.informationId));
    } catch (e) {
      emit(InformationError('Failed to delete information: $e'));
    }
  }

  Future<void> _onSearchInformation(
    SearchInformation event,
    Emitter<InformationState> emit,
  ) async {
    emit(InformationLoading());
    try {
      final information = await _informationRepository.searchByContent(event.query);
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
}