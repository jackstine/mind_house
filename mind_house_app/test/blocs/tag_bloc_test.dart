import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mind_house_app/blocs/tag/tag.dart';
import 'package:mind_house_app/blocs/base/base_event.dart';
import 'package:mind_house_app/blocs/base/base_state.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/repositories/interfaces/tag_repository_interface.dart';
import 'package:mind_house_app/repositories/tag_repository.dart';
import 'package:mind_house_app/database/database_helper.dart';

// Generate mocks
@GenerateMocks([ITagRepository])
import 'tag_bloc_test.mocks.dart';

void main() {
  group('TagBloc', () {
    late TagBloc tagBloc;
    late MockITagRepository mockTagRepository;

    // Test data
    final tag1 = Tag(
      id: 'tag1',
      name: 'flutter',
      displayName: 'Flutter',
      color: '#2196F3',
      usageCount: 5,
    );

    final tag2 = Tag(
      id: 'tag2',
      name: 'dart',
      displayName: 'Dart',
      color: '#FF5722',
      usageCount: 3,
    );

    final testTags = [tag1, tag2];

    setUp(() {
      mockTagRepository = MockITagRepository();
      tagBloc = TagBloc(tagRepository: mockTagRepository);
    });

    tearDown(() {
      tagBloc.close();
    });

    test('initial state is TagInitialState', () {
      expect(tagBloc.state, equals(const TagInitialState()));
    });

    group('LoadAllTagsEvent', () {
      blocTest<TagBloc, BaseState>(
        'emits TagsLoadedState when tags are loaded successfully',
        build: () {
          when(mockTagRepository.getAll(limit: null, offset: null))
              .thenAnswer((_) async => testTags);
          return tagBloc;
        },
        act: (bloc) => bloc.add(const LoadAllTagsEvent()),
        expect: () => [
          const TagLoadingState(),
          TagsLoadedState(testTags),
        ],
        verify: (_) {
          verify(mockTagRepository.getAll(limit: null, offset: null)).called(1);
        },
      );

      blocTest<TagBloc, BaseState>(
        'emits TagErrorState when loading fails',
        build: () {
          when(mockTagRepository.getAll(limit: null, offset: null))
              .thenThrow(MindHouseDatabaseException(
                message: 'Database error',
                type: DatabaseErrorType.connection,
                operation: 'getAll',
              ));
          return tagBloc;
        },
        act: (bloc) => bloc.add(const LoadAllTagsEvent()),
        expect: () => [
          const TagLoadingState(),
          isA<TagErrorState>(),
        ],
      );
    });

    group('LoadTagByIdEvent', () {
      blocTest<TagBloc, BaseState>(
        'emits TagLoadedState when tag is found',
        build: () {
          when(mockTagRepository.getById('tag1'))
              .thenAnswer((_) async => tag1);
          return tagBloc;
        },
        act: (bloc) => bloc.add(const LoadTagByIdEvent('tag1')),
        expect: () => [
          const TagLoadingState(),
          TagLoadedState(tag1),
        ],
      );

      blocTest<TagBloc, BaseState>(
        'emits TagErrorState when tag is not found',
        build: () {
          when(mockTagRepository.getById('nonexistent'))
              .thenAnswer((_) async => null);
          return tagBloc;
        },
        act: (bloc) => bloc.add(const LoadTagByIdEvent('nonexistent')),
        expect: () => [
          const TagLoadingState(),
          isA<TagErrorState>(),
        ],
      );
    });

    group('CreateTagEvent', () {
      blocTest<TagBloc, BaseState>(
        'emits TagCreatedState when tag is created successfully',
        build: () {
          when(mockTagRepository.getByName(tag1.name))
              .thenAnswer((_) async => null);
          when(mockTagRepository.create(tag1))
              .thenAnswer((_) async => tag1.id);
          when(mockTagRepository.getById(tag1.id))
              .thenAnswer((_) async => tag1);
          return tagBloc;
        },
        act: (bloc) => bloc.add(CreateTagEvent(tag1)),
        expect: () => [
          const TagCreatingState(),
          TagCreatedState(tag1),
        ],
      );

      blocTest<TagBloc, BaseState>(
        'emits TagCreationErrorState when tag already exists',
        build: () {
          when(mockTagRepository.getByName(tag1.name))
              .thenAnswer((_) async => tag1);
          return tagBloc;
        },
        act: (bloc) => bloc.add(CreateTagEvent(tag1)),
        expect: () => [
          const TagCreatingState(),
          isA<TagCreationErrorState>(),
        ],
      );
    });

    group('SearchTagsEvent', () {
      blocTest<TagBloc, BaseState>(
        'emits TagsLoadedState with search results',
        build: () {
          when(mockTagRepository.searchByName('flutter', limit: null, offset: null))
              .thenAnswer((_) async => [tag1]);
          return tagBloc;
        },
        act: (bloc) => bloc.add(const SearchTagsEvent('flutter')),
        expect: () => [
          const TagSearchingState(),
          TagsLoadedState([tag1]),
        ],
      );

      blocTest<TagBloc, BaseState>(
        'emits empty TagsLoadedState for empty query',
        build: () => tagBloc,
        act: (bloc) => bloc.add(const SearchTagsEvent('')),
        expect: () => [
          const TagSearchingState(),
          const TagsLoadedState([]),
        ],
      );
    });

    group('GetTagSuggestionsEvent', () {
      blocTest<TagBloc, BaseState>(
        'emits TagSuggestionsLoadedState with suggestions',
        build: () {
          when(mockTagRepository.getSuggestions('fl', limit: 5))
              .thenAnswer((_) async => [tag1]);
          return tagBloc;
        },
        act: (bloc) => bloc.add(const GetTagSuggestionsEvent('fl')),
        expect: () => [
          const TagSuggestionsLoadingState(),
          TagSuggestionsLoadedState([tag1], query: 'fl'),
        ],
      );
    });

    group('UpdateTagEvent', () {
      blocTest<TagBloc, BaseState>(
        'emits TagUpdatedState when update succeeds',
        build: () {
          when(mockTagRepository.update(tag1))
              .thenAnswer((_) async => true);
          return tagBloc;
        },
        act: (bloc) => bloc.add(UpdateTagEvent(tag1)),
        expect: () => [
          const TagUpdatingState(),
          TagUpdatedState(tag1),
        ],
      );

      blocTest<TagBloc, BaseState>(
        'emits TagUpdateErrorState when update fails',
        build: () {
          when(mockTagRepository.update(tag1))
              .thenAnswer((_) async => false);
          return tagBloc;
        },
        act: (bloc) => bloc.add(UpdateTagEvent(tag1)),
        expect: () => [
          const TagUpdatingState(),
          isA<TagUpdateErrorState>(),
        ],
      );
    });

    group('DeleteTagEvent', () {
      blocTest<TagBloc, BaseState>(
        'emits TagDeletedState when deletion succeeds',
        build: () {
          when(mockTagRepository.delete('tag1'))
              .thenAnswer((_) async => true);
          return tagBloc;
        },
        act: (bloc) => bloc.add(const DeleteTagEvent('tag1')),
        expect: () => [
          const TagDeletingState(),
          const TagDeletedState('tag1'),
        ],
      );
    });

    group('ValidateTagEvent', () {
      blocTest<TagBloc, BaseState>(
        'emits TagValidationSuccessState for valid tag name',
        build: () => tagBloc,
        act: (bloc) => bloc.add(const ValidateTagEvent('Valid Tag')),
        expect: () => [
          isA<TagValidationSuccessState>(),
        ],
      );

      blocTest<TagBloc, BaseState>(
        'emits TagValidationErrorState for invalid tag name',
        build: () => tagBloc,
        act: (bloc) => bloc.add(const ValidateTagEvent('')),
        expect: () => [
          isA<TagValidationErrorState>(),
        ],
      );
    });

    group('Integration Tests', () {
      test('TagBloc can be instantiated with default repository', () {
        expect(() => TagBloc(), returnsNormally);
      });

      test('TagBloc can be instantiated with custom repository', () {
        final mockRepo = MockITagRepository();
        expect(() => TagBloc(tagRepository: mockRepo), returnsNormally);
      });
    });
  });

  group('TagState Extensions', () {
    test('TagsLoadedState convenience methods work correctly', () {
      final tags = [
        Tag(name: 'tag1', displayName: 'Tag 1'),
        Tag(name: 'tag2', displayName: 'Tag 2'),
      ];
      final state = TagsLoadedState(tags);

      expect(state.tags, equals(tags));
      expect(state.hasTags, isTrue);
      expect(state.count, equals(2));
    });

    test('TagsLoadedState with empty list', () {
      const state = TagsLoadedState([]);

      expect(state.tags, isEmpty);
      expect(state.hasTags, isFalse);
      expect(state.count, equals(0));
    });
  });
}