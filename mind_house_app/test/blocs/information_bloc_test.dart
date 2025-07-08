import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mind_house_app/blocs/information/information.dart';
import 'package:mind_house_app/blocs/base/crud_events.dart';
import 'package:mind_house_app/blocs/base/crud_states.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/models/information_tag.dart';
import 'package:mind_house_app/repositories/information_repository.dart';
import 'package:mind_house_app/database/database_helper.dart';

/// Mock repository for testing Information BLoC
class MockInformationRepository implements InformationRepository {
  final List<Information> _informationItems = [];
  final List<InformationTag> _tagAssignments = [];
  
  @override
  Future<String> create(Information information) async {
    _informationItems.add(information);
    return information.id;
  }

  @override
  Future<Information?> getById(String id) async {
    try {
      return _informationItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> update(Information information) async {
    final index = _informationItems.indexWhere((item) => item.id == information.id);
    if (index >= 0) {
      _informationItems[index] = information;
      return true;
    }
    return false;
  }

  @override
  Future<bool> delete(String id) async {
    final index = _informationItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _informationItems.removeAt(index);
      return true;
    }
    return false;
  }

  @override
  Future<List<Information>> getAll({int? limit, int? offset}) async {
    var items = List<Information>.from(_informationItems);
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (offset != null) {
      items = items.skip(offset).toList();
    }
    if (limit != null) {
      items = items.take(limit).toList();
    }
    
    return items;
  }

  @override
  Future<List<Information>> getAllSorted({
    required SortField sortBy,
    required SortOrder sortOrder,
    int? limit,
    int? offset,
  }) async {
    var items = List<Information>.from(_informationItems);
    
    // Sort logic
    items.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case SortField.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case SortField.updatedAt:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case SortField.title:
          comparison = a.title.compareTo(b.title);
          break;
        case SortField.importance:
          comparison = a.importance.compareTo(b.importance);
          break;
        case SortField.accessedAt:
          if (a.accessedAt == null && b.accessedAt == null) return 0;
          if (a.accessedAt == null) return 1;
          if (b.accessedAt == null) return -1;
          comparison = a.accessedAt!.compareTo(b.accessedAt!);
          break;
      }
      
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
    
    if (offset != null) {
      items = items.skip(offset).toList();
    }
    if (limit != null) {
      items = items.take(limit).toList();
    }
    
    return items;
  }

  @override
  Future<List<Information>> getByType(InformationType type, {int? limit, int? offset}) async {
    var items = _informationItems.where((item) => item.type == type).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (offset != null) {
      items = items.skip(offset).toList();
    }
    if (limit != null) {
      items = items.take(limit).toList();
    }
    
    return items;
  }

  @override
  Future<List<Information>> getFavorites({int? limit, int? offset}) async {
    var items = _informationItems.where((item) => item.isFavorite).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (offset != null) {
      items = items.skip(offset).toList();
    }
    if (limit != null) {
      items = items.take(limit).toList();
    }
    
    return items;
  }

  @override
  Future<List<Information>> getArchived({int? limit, int? offset}) async {
    var items = _informationItems.where((item) => item.isArchived).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (offset != null) {
      items = items.skip(offset).toList();
    }
    if (limit != null) {
      items = items.take(limit).toList();
    }
    
    return items;
  }

  @override
  Future<List<Information>> search(String query, {int? limit, int? offset}) async {
    if (query.trim().isEmpty) return [];
    
    final queryLower = query.toLowerCase();
    var items = _informationItems.where((item) =>
        item.title.toLowerCase().contains(queryLower) ||
        item.content.toLowerCase().contains(queryLower)).toList();
    
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (offset != null) {
      items = items.skip(offset).toList();
    }
    if (limit != null) {
      items = items.take(limit).toList();
    }
    
    return items;
  }

  @override
  Future<bool> markAsAccessed(String id) async {
    final index = _informationItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _informationItems[index] = _informationItems[index].markAsAccessed();
      return true;
    }
    return false;
  }

  @override
  Future<int> getCount({InformationType? type, bool? isFavorite, bool? isArchived}) async {
    var items = _informationItems;
    
    if (type != null) {
      items = items.where((item) => item.type == type).toList();
    }
    if (isFavorite != null) {
      items = items.where((item) => item.isFavorite == isFavorite).toList();
    }
    if (isArchived != null) {
      items = items.where((item) => item.isArchived == isArchived).toList();
    }
    
    return items.length;
  }

  @override
  Future<List<Information>> getRecentlyAccessed({int limit = 10}) async {
    var items = _informationItems.where((item) => item.accessedAt != null).toList();
    items.sort((a, b) => b.accessedAt!.compareTo(a.accessedAt!));
    
    return items.take(limit).toList();
  }

  @override
  Future<List<Information>> getByImportance(
    int minImportance, {
    int? maxImportance,
    int? limit,
    int? offset,
  }) async {
    var items = _informationItems.where((item) {
      if (maxImportance != null) {
        return item.importance >= minImportance && item.importance <= maxImportance;
      } else {
        return item.importance >= minImportance;
      }
    }).toList();
    
    items.sort((a, b) {
      final importanceComparison = b.importance.compareTo(a.importance);
      if (importanceComparison != 0) return importanceComparison;
      return b.createdAt.compareTo(a.createdAt);
    });
    
    if (offset != null) {
      items = items.skip(offset).toList();
    }
    if (limit != null) {
      items = items.take(limit).toList();
    }
    
    return items;
  }

  @override
  Future<void> addTags(String informationId, List<String> tagIds) async {
    for (final tagId in tagIds) {
      if (!_tagAssignments.any((assignment) => 
          assignment.informationId == informationId && assignment.tagId == tagId)) {
        _tagAssignments.add(InformationTag(
          informationId: informationId,
          tagId: tagId,
        ));
      }
    }
  }

  @override
  Future<void> removeTags(String informationId, List<String> tagIds) async {
    _tagAssignments.removeWhere((assignment) =>
        assignment.informationId == informationId && tagIds.contains(assignment.tagId));
  }

  @override
  Future<void> updateTags(String informationId, List<String> newTagIds) async {
    // Remove existing tags for this information
    _tagAssignments.removeWhere((assignment) => assignment.informationId == informationId);
    
    // Add new tags
    for (final tagId in newTagIds) {
      _tagAssignments.add(InformationTag(
        informationId: informationId,
        tagId: tagId,
      ));
    }
  }

  @override
  Future<List<InformationTag>> getTagAssignments(String informationId) async {
    return _tagAssignments.where((assignment) => assignment.informationId == informationId).toList();
  }

  @override
  Future<List<String>> getTagIds(String informationId) async {
    return _tagAssignments
        .where((assignment) => assignment.informationId == informationId)
        .map((assignment) => assignment.tagId)
        .toList();
  }

  @override
  Future<List<Information>> getByTagIds(
    List<String> tagIds, {
    bool requireAllTags = false,
    int? limit,
    int? offset,
  }) async {
    if (tagIds.isEmpty) return [];
    
    final informationIds = <String>{};
    
    if (requireAllTags) {
      // Information must have ALL specified tags
      final informationWithAllTags = <String, Set<String>>{};
      
      for (final assignment in _tagAssignments) {
        if (tagIds.contains(assignment.tagId)) {
          informationWithAllTags.putIfAbsent(assignment.informationId, () => <String>{});
          informationWithAllTags[assignment.informationId]!.add(assignment.tagId);
        }
      }
      
      for (final entry in informationWithAllTags.entries) {
        if (entry.value.length == tagIds.length) {
          informationIds.add(entry.key);
        }
      }
    } else {
      // Information must have AT LEAST ONE of the specified tags
      for (final assignment in _tagAssignments) {
        if (tagIds.contains(assignment.tagId)) {
          informationIds.add(assignment.informationId);
        }
      }
    }
    
    var items = _informationItems.where((item) => informationIds.contains(item.id)).toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    if (offset != null) {
      items = items.skip(offset).toList();
    }
    if (limit != null) {
      items = items.take(limit).toList();
    }
    
    return items;
  }

  // Helper methods for testing
  void clear() {
    _informationItems.clear();
    _tagAssignments.clear();
  }

  void addInformationItem(Information information) {
    _informationItems.add(information);
  }

  void addTagAssignment(InformationTag assignment) {
    _tagAssignments.add(assignment);
  }
}

/// Mock repository that throws exceptions for testing error handling
class FailingMockInformationRepository implements InformationRepository {
  @override
  Future<String> create(Information information) async {
    throw Exception('Database connection failed');
  }

  @override
  Future<Information?> getById(String id) async {
    throw Exception('Database query failed');
  }

  @override
  Future<bool> update(Information information) async {
    throw Exception('Database update failed');
  }

  @override
  Future<bool> delete(String id) async {
    throw Exception('Database delete failed');
  }

  @override
  Future<List<Information>> getAll({int? limit, int? offset}) async {
    throw Exception('Database query failed');
  }

  @override
  Future<List<Information>> getAllSorted({
    required SortField sortBy,
    required SortOrder sortOrder,
    int? limit,
    int? offset,
  }) async {
    throw Exception('Database query failed');
  }

  @override
  Future<List<Information>> getByType(InformationType type, {int? limit, int? offset}) async {
    throw Exception('Database query failed');
  }

  @override
  Future<List<Information>> getFavorites({int? limit, int? offset}) async {
    throw Exception('Database query failed');
  }

  @override
  Future<List<Information>> getArchived({int? limit, int? offset}) async {
    throw Exception('Database query failed');
  }

  @override
  Future<List<Information>> search(String query, {int? limit, int? offset}) async {
    throw Exception('Database search failed');
  }

  @override
  Future<bool> markAsAccessed(String id) async {
    throw Exception('Database update failed');
  }

  @override
  Future<int> getCount({InformationType? type, bool? isFavorite, bool? isArchived}) async {
    throw Exception('Database count failed');
  }

  @override
  Future<List<Information>> getRecentlyAccessed({int limit = 10}) async {
    throw Exception('Database query failed');
  }

  @override
  Future<List<Information>> getByImportance(
    int minImportance, {
    int? maxImportance,
    int? limit,
    int? offset,
  }) async {
    throw Exception('Database query failed');
  }

  @override
  Future<void> addTags(String informationId, List<String> tagIds) async {
    throw Exception('Database tag operation failed');
  }

  @override
  Future<void> removeTags(String informationId, List<String> tagIds) async {
    throw Exception('Database tag operation failed');
  }

  @override
  Future<void> updateTags(String informationId, List<String> newTagIds) async {
    throw Exception('Database tag operation failed');
  }

  @override
  Future<List<InformationTag>> getTagAssignments(String informationId) async {
    throw Exception('Database query failed');
  }

  @override
  Future<List<String>> getTagIds(String informationId) async {
    throw Exception('Database query failed');
  }

  @override
  Future<List<Information>> getByTagIds(
    List<String> tagIds, {
    bool requireAllTags = false,
    int? limit,
    int? offset,
  }) async {
    throw Exception('Database query failed');
  }
}

void main() {
  group('InformationBloc', () {
    late MockInformationRepository mockRepository;
    late InformationBloc informationBloc;

    // Test data
    final testInformation1 = Information(
      id: 'test-id-1',
      title: 'Test Information 1',
      content: 'This is test content 1',
      type: InformationType.note,
      importance: 5,
      isFavorite: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final testInformation2 = Information(
      id: 'test-id-2',
      title: 'Test Information 2',
      content: 'This is test content 2',
      type: InformationType.bookmark,
      importance: 8,
      isArchived: true,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    );

    final testInformation3 = Information(
      id: 'test-id-3',
      title: 'Important Task',
      content: 'This is an important task',
      type: InformationType.task,
      importance: 10,
      isFavorite: true,
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
      accessedAt: DateTime(2024, 1, 4),
    );

    setUp(() {
      mockRepository = MockInformationRepository();
      informationBloc = InformationBloc(mockRepository);
    });

    tearDown(() {
      informationBloc.close();
      mockRepository.clear();
    });

    test('initial state is CrudInitialState', () {
      expect(informationBloc.state, equals(const CrudInitialState()));
    });

    group('CRUD Operations', () {
      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, CrudLoadedState] when LoadAllEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          mockRepository.addInformationItem(testInformation2);
          return informationBloc;
        },
        act: (bloc) => bloc.add(const LoadAllEvent()),
        expect: () => [
          const CrudLoadingState(),
          isA<CrudLoadedState<Information>>()
              .having((state) => state.items.length, 'items length', 2),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, CrudItemLoadedState] when LoadByIdEvent is added with valid ID',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          return informationBloc;
        },
        act: (bloc) => bloc.add(const LoadByIdEvent('test-id-1')),
        expect: () => [
          const CrudLoadingState(),
          isA<CrudItemLoadedState<Information>>()
              .having((state) => state.item.id, 'item id', 'test-id-1'),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, CrudErrorState] when LoadByIdEvent is added with invalid ID',
        build: () => informationBloc,
        act: (bloc) => bloc.add(const LoadByIdEvent('invalid-id')),
        expect: () => [
          const CrudLoadingState(),
          isA<CrudErrorState>()
              .having((state) => state.message, 'error message', contains('not found')),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudCreatingState, CrudCreatedState] when CreateItemEvent is added',
        build: () => informationBloc,
        act: (bloc) => bloc.add(CreateItemEvent<Information>(testInformation1)),
        expect: () => [
          const CrudCreatingState(),
          isA<CrudCreatedState<Information>>()
              .having((state) => state.item.id, 'created item id', 'test-id-1'),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudUpdatingState, CrudUpdatedState] when UpdateItemEvent is added with existing item',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          return informationBloc;
        },
        act: (bloc) {
          final updatedInfo = testInformation1.copyWith(title: 'Updated Title');
          return bloc.add(UpdateItemEvent<Information>(updatedInfo));
        },
        expect: () => [
          const CrudUpdatingState(),
          isA<CrudUpdatedState<Information>>()
              .having((state) => state.item.title, 'updated title', 'Updated Title'),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudDeletingState, CrudDeletedState] when DeleteItemEvent is added with existing item',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          return informationBloc;
        },
        act: (bloc) => bloc.add(const DeleteItemEvent('test-id-1')),
        expect: () => [
          const CrudDeletingState(),
          isA<CrudDeletedState>()
              .having((state) => state.id, 'deleted id', 'test-id-1'),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudSearchingState, CrudSearchResultsState] when SearchEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          mockRepository.addInformationItem(testInformation2);
          return informationBloc;
        },
        act: (bloc) => bloc.add(const SearchEvent('Test Information')),
        expect: () => [
          const CrudSearchingState(),
          isA<CrudSearchResultsState<Information>>()
              .having((state) => state.results.length, 'search results length', 2)
              .having((state) => state.query, 'search query', 'Test Information'),
        ],
      );
    });

    group('Information-Specific Operations', () {
      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, InformationLoadedByTypeState] when LoadByTypeEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1); // note
          mockRepository.addInformationItem(testInformation2); // bookmark
          mockRepository.addInformationItem(testInformation3); // task
          return informationBloc;
        },
        act: (bloc) => bloc.add(const LoadByTypeEvent(InformationType.note)),
        expect: () => [
          const CrudLoadingState(),
          isA<InformationLoadedByTypeState>()
              .having((state) => state.informationItems.length, 'filtered items length', 1)
              .having((state) => state.type, 'filter type', InformationType.note),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, FavoritesLoadedState] when LoadFavoritesEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1); // favorite
          mockRepository.addInformationItem(testInformation2); // not favorite
          mockRepository.addInformationItem(testInformation3); // favorite
          return informationBloc;
        },
        act: (bloc) => bloc.add(const LoadFavoritesEvent()),
        expect: () => [
          const CrudLoadingState(),
          isA<FavoritesLoadedState>()
              .having((state) => state.favorites.length, 'favorites length', 2),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, ArchivedLoadedState] when LoadArchivedEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1); // not archived
          mockRepository.addInformationItem(testInformation2); // archived
          mockRepository.addInformationItem(testInformation3); // not archived
          return informationBloc;
        },
        act: (bloc) => bloc.add(const LoadArchivedEvent()),
        expect: () => [
          const CrudLoadingState(),
          isA<ArchivedLoadedState>()
              .having((state) => state.archived.length, 'archived length', 1),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, RecentlyAccessedLoadedState] when LoadRecentlyAccessedEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1); // no access
          mockRepository.addInformationItem(testInformation2); // no access
          mockRepository.addInformationItem(testInformation3); // accessed
          return informationBloc;
        },
        act: (bloc) => bloc.add(const LoadRecentlyAccessedEvent()),
        expect: () => [
          const CrudLoadingState(),
          isA<RecentlyAccessedLoadedState>()
              .having((state) => state.recentlyAccessed.length, 'recently accessed length', 1),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, InformationLoadedByImportanceState] when LoadByImportanceEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1); // importance 5
          mockRepository.addInformationItem(testInformation2); // importance 8
          mockRepository.addInformationItem(testInformation3); // importance 10
          return informationBloc;
        },
        act: (bloc) => bloc.add(const LoadByImportanceEvent(8)),
        expect: () => [
          const CrudLoadingState(),
          isA<InformationLoadedByImportanceState>()
              .having((state) => state.informationItems.length, 'high importance items', 2)
              .having((state) => state.minImportance, 'min importance', 8),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [MarkedAsAccessedState] when MarkAsAccessedEvent is added with existing item',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          return informationBloc;
        },
        act: (bloc) => bloc.add(const MarkAsAccessedEvent('test-id-1')),
        expect: () => [
          isA<MarkedAsAccessedState>()
              .having((state) => state.informationId, 'accessed id', 'test-id-1'),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [InformationCountState] when GetCountEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          mockRepository.addInformationItem(testInformation2);
          mockRepository.addInformationItem(testInformation3);
          return informationBloc;
        },
        act: (bloc) => bloc.add(const GetCountEvent(isFavorite: true)),
        expect: () => [
          isA<InformationCountState>()
              .having((state) => state.count, 'favorite count', 2)
              .having((state) => state.isFavorite, 'is favorite filter', true),
        ],
      );
    });

    group('Tag Management Operations', () {
      blocTest<InformationBloc, CrudState>(
        'emits [TagOperationInProgressState, TagsAddedState] when AddTagsEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          return informationBloc;
        },
        act: (bloc) => bloc.add(const AddTagsEvent('test-id-1', ['tag-1', 'tag-2'])),
        expect: () => [
          isA<TagOperationInProgressState>()
              .having((state) => state.operation, 'operation', 'adding')
              .having((state) => state.informationId, 'information id', 'test-id-1'),
          isA<TagsAddedState>()
              .having((state) => state.informationId, 'information id', 'test-id-1')
              .having((state) => state.tagIds.length, 'added tags count', 2),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [TagOperationInProgressState, TagsRemovedState] when RemoveTagsEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          mockRepository.addTagAssignment(InformationTag(
            informationId: 'test-id-1',
            tagId: 'tag-1',
          ));
          return informationBloc;
        },
        act: (bloc) => bloc.add(const RemoveTagsEvent('test-id-1', ['tag-1'])),
        expect: () => [
          isA<TagOperationInProgressState>()
              .having((state) => state.operation, 'operation', 'removing'),
          isA<TagsRemovedState>()
              .having((state) => state.informationId, 'information id', 'test-id-1'),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [TagOperationInProgressState, TagsUpdatedState] when UpdateTagsEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          return informationBloc;
        },
        act: (bloc) => bloc.add(const UpdateTagsEvent('test-id-1', ['tag-1', 'tag-2', 'tag-3'])),
        expect: () => [
          isA<TagOperationInProgressState>()
              .having((state) => state.operation, 'operation', 'updating'),
          isA<TagsUpdatedState>()
              .having((state) => state.informationId, 'information id', 'test-id-1')
              .having((state) => state.tagIds.length, 'updated tags count', 3),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, TagAssignmentsLoadedState] when LoadTagAssignmentsEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          mockRepository.addTagAssignment(InformationTag(
            informationId: 'test-id-1',
            tagId: 'tag-1',
          ));
          mockRepository.addTagAssignment(InformationTag(
            informationId: 'test-id-1',
            tagId: 'tag-2',
          ));
          return informationBloc;
        },
        act: (bloc) => bloc.add(const LoadTagAssignmentsEvent('test-id-1')),
        expect: () => [
          const CrudLoadingState(),
          isA<TagAssignmentsLoadedState>()
              .having((state) => state.informationId, 'information id', 'test-id-1')
              .having((state) => state.assignments.length, 'assignments length', 2),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, TagIdsLoadedState] when LoadTagIdsEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          mockRepository.addTagAssignment(InformationTag(
            informationId: 'test-id-1',
            tagId: 'tag-1',
          ));
          return informationBloc;
        },
        act: (bloc) => bloc.add(const LoadTagIdsEvent('test-id-1')),
        expect: () => [
          const CrudLoadingState(),
          isA<TagIdsLoadedState>()
              .having((state) => state.informationId, 'information id', 'test-id-1')
              .having((state) => state.tagIds.length, 'tag ids length', 1),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits [CrudLoadingState, InformationLoadedByTagIdsState] when LoadByTagIdsEvent is added',
        build: () {
          mockRepository.addInformationItem(testInformation1);
          mockRepository.addInformationItem(testInformation2);
          mockRepository.addTagAssignment(InformationTag(
            informationId: 'test-id-1',
            tagId: 'tag-1',
          ));
          mockRepository.addTagAssignment(InformationTag(
            informationId: 'test-id-2',
            tagId: 'tag-1',
          ));
          return informationBloc;
        },
        act: (bloc) => bloc.add(const LoadByTagIdsEvent(['tag-1'])),
        expect: () => [
          const CrudLoadingState(),
          isA<InformationLoadedByTagIdsState>()
              .having((state) => state.informationItems.length, 'tagged items length', 2)
              .having((state) => state.tagIds, 'tag ids', ['tag-1'])
              .having((state) => state.requireAllTags, 'require all tags', false),
        ],
      );
    });

    group('Convenience Methods', () {
      test('loadAll() adds LoadAllEvent', () {
        expectLater(
          informationBloc.stream,
          emitsInOrder([
            const CrudLoadingState(),
            isA<CrudLoadedState<Information>>(),
          ]),
        );
        informationBloc.loadAll();
      });

      test('loadById() adds LoadByIdEvent', () {
        mockRepository.addInformationItem(testInformation1);
        expectLater(
          informationBloc.stream,
          emitsInOrder([
            const CrudLoadingState(),
            isA<CrudItemLoadedState<Information>>(),
          ]),
        );
        informationBloc.loadById('test-id-1');
      });

      test('create() adds CreateItemEvent', () {
        expectLater(
          informationBloc.stream,
          emitsInOrder([
            const CrudCreatingState(),
            isA<CrudCreatedState<Information>>(),
          ]),
        );
        informationBloc.create(testInformation1);
      });

      test('loadByType() adds LoadByTypeEvent', () {
        mockRepository.addInformationItem(testInformation1);
        expectLater(
          informationBloc.stream,
          emitsInOrder([
            const CrudLoadingState(),
            isA<InformationLoadedByTypeState>(),
          ]),
        );
        informationBloc.loadByType(InformationType.note);
      });

      test('loadFavorites() adds LoadFavoritesEvent', () {
        mockRepository.addInformationItem(testInformation1);
        expectLater(
          informationBloc.stream,
          emitsInOrder([
            const CrudLoadingState(),
            isA<FavoritesLoadedState>(),
          ]),
        );
        informationBloc.loadFavorites();
      });

      test('addTags() adds AddTagsEvent', () {
        mockRepository.addInformationItem(testInformation1);
        expectLater(
          informationBloc.stream,
          emitsInOrder([
            isA<TagOperationInProgressState>(),
            isA<TagsAddedState>(),
          ]),
        );
        informationBloc.addTags('test-id-1', ['tag-1']);
      });
    });

    group('Error Handling', () {
      blocTest<InformationBloc, CrudState>(
        'emits CrudErrorState when repository throws exception during create',
        build: () {
          final failingRepository = FailingMockInformationRepository();
          return InformationBloc(failingRepository);
        },
        act: (bloc) => bloc.add(CreateItemEvent<Information>(testInformation1)),
        expect: () => [
          const CrudCreatingState(),
          isA<CrudErrorState>()
              .having((state) => state.message, 'error message', contains('Failed to create')),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits CrudErrorState when repository throws exception during update',
        build: () {
          final failingRepository = FailingMockInformationRepository();
          return InformationBloc(failingRepository);
        },
        act: (bloc) => bloc.add(UpdateItemEvent<Information>(testInformation1)),
        expect: () => [
          const CrudUpdatingState(),
          isA<CrudErrorState>()
              .having((state) => state.message, 'error message', contains('Failed to update')),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits CrudErrorState when repository throws exception during delete',
        build: () {
          final failingRepository = FailingMockInformationRepository();
          return InformationBloc(failingRepository);
        },
        act: (bloc) => bloc.add(const DeleteItemEvent('test-id')),
        expect: () => [
          const CrudDeletingState(),
          isA<CrudErrorState>()
              .having((state) => state.message, 'error message', contains('Failed to delete')),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits CrudErrorState when repository throws exception during markAsAccessed',
        build: () {
          final failingRepository = FailingMockInformationRepository();
          return InformationBloc(failingRepository);
        },
        act: (bloc) => bloc.add(const MarkAsAccessedEvent('test-id')),
        expect: () => [
          isA<CrudErrorState>()
              .having((state) => state.message, 'error message', contains('Failed to mark')),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits CrudErrorState when update fails for non-existent item',
        build: () => informationBloc,
        act: (bloc) => bloc.add(UpdateItemEvent<Information>(testInformation1)),
        expect: () => [
          const CrudUpdatingState(),
          isA<CrudErrorState>()
              .having((state) => state.message, 'error message', contains('Failed to update')),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits CrudErrorState when delete fails for non-existent item',
        build: () => informationBloc,
        act: (bloc) => bloc.add(const DeleteItemEvent('non-existent-id')),
        expect: () => [
          const CrudDeletingState(),
          isA<CrudErrorState>()
              .having((state) => state.message, 'error message', contains('Failed to delete')),
        ],
      );

      blocTest<InformationBloc, CrudState>(
        'emits CrudErrorState when markAsAccessed fails for non-existent item',
        build: () => informationBloc,
        act: (bloc) => bloc.add(const MarkAsAccessedEvent('non-existent-id')),
        expect: () => [
          isA<CrudErrorState>()
              .having((state) => state.message, 'error message', contains('not found')),
        ],
      );
    });
  });
}