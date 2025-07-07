import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mind_house_app/blocs/information_bloc.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/services/information_service.dart';
import '../helpers/test_data_factory.dart';
import '../mocks/mock_repositories.mocks.dart';

/// Unit tests for InformationBloc using bloc_test
void main() {
  group('InformationBloc Tests', () {
    late MockInformationRepository mockInformationRepository;
    late MockTagRepository mockTagRepository;
    late InformationService informationService;
    late InformationBloc informationBloc;

    setUp(() {
      mockInformationRepository = MockInformationRepository();
      mockTagRepository = MockTagRepository();
      informationService = InformationService(
        informationRepository: mockInformationRepository,
        tagRepository: mockTagRepository,
        tagService: TagService(mockTagRepository),
      );
      informationBloc = InformationBloc(informationService: informationService);
    });

    tearDown(() {
      informationBloc.close();
    });

    test('initial state should be InformationInitial', () {
      expect(informationBloc.state, equals(InformationInitial()));
    });

    group('LoadInformation', () {
      blocTest<InformationBloc, InformationState>(
        'emits [InformationLoading, InformationLoaded] when LoadInformation is successful',
        build: () {
          final testInformation = TestDataFactory.createInformationList(3);
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => testInformation);
          return informationBloc;
        },
        act: (bloc) => bloc.add(LoadInformation()),
        expect: () => [
          InformationLoading(),
          isA<InformationLoaded>()
              .having((state) => state.information.length, 'information length', 3),
        ],
        verify: (_) {
          verify(mockInformationRepository.getAll()).called(1);
        },
      );

      blocTest<InformationBloc, InformationState>(
        'emits [InformationLoading, InformationError] when LoadInformation fails',
        build: () {
          when(mockInformationRepository.getAll())
              .thenThrow(Exception('Database error'));
          return informationBloc;
        },
        act: (bloc) => bloc.add(LoadInformation()),
        expect: () => [
          InformationLoading(),
          isA<InformationError>()
              .having((state) => state.message, 'error message', contains('Database error')),
        ],
      );

      blocTest<InformationBloc, InformationState>(
        'emits [InformationLoading, InformationLoaded] with empty list when no information exists',
        build: () {
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => []);
          return informationBloc;
        },
        act: (bloc) => bloc.add(LoadInformation()),
        expect: () => [
          InformationLoading(),
          isA<InformationLoaded>()
              .having((state) => state.information.length, 'information length', 0),
        ],
      );
    });

    group('CreateInformation', () {
      blocTest<InformationBloc, InformationState>(
        'emits [InformationSaving, InformationSaved] when CreateInformation is successful',
        build: () {
          final testInfo = TestDataFactory.createInformation(content: 'Test content');
          when(mockInformationRepository.create(any))
              .thenAnswer((_) async => testInfo);
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => [testInfo]);
          return informationBloc;
        },
        act: (bloc) => bloc.add(CreateInformation(
          content: 'Test content',
          tagNames: ['flutter', 'test'],
        )),
        expect: () => [
          InformationSaving(),
          InformationSaved(),
          isA<InformationLoaded>()
              .having((state) => state.information.length, 'information length', 1),
        ],
        verify: (_) {
          verify(mockInformationRepository.create(any)).called(1);
          verify(mockInformationRepository.getAll()).called(1);
        },
      );

      blocTest<InformationBloc, InformationState>(
        'emits [InformationSaving, InformationError] when CreateInformation fails',
        build: () {
          when(mockInformationRepository.create(any))
              .thenThrow(Exception('Save failed'));
          return informationBloc;
        },
        act: (bloc) => bloc.add(CreateInformation(
          content: 'Test content',
          tagNames: [],
        )),
        expect: () => [
          InformationSaving(),
          isA<InformationError>()
              .having((state) => state.message, 'error message', contains('Save failed')),
        ],
      );

      blocTest<InformationBloc, InformationState>(
        'emits error when trying to create information with empty content',
        build: () => informationBloc,
        act: (bloc) => bloc.add(CreateInformation(
          content: '',
          tagNames: [],
        )),
        expect: () => [
          isA<InformationError>()
              .having((state) => state.message, 'error message', contains('empty')),
        ],
      );

      blocTest<InformationBloc, InformationState>(
        'emits error when trying to create information with whitespace-only content',
        build: () => informationBloc,
        act: (bloc) => bloc.add(CreateInformation(
          content: '   ',
          tagNames: [],
        )),
        expect: () => [
          isA<InformationError>()
              .having((state) => state.message, 'error message', contains('empty')),
        ],
      );
    });

    group('UpdateInformation', () {
      blocTest<InformationBloc, InformationState>(
        'emits [InformationSaving, InformationSaved] when UpdateInformation is successful',
        build: () {
          final testInfo = TestDataFactory.createInformation(
            id: 'test-id',
            content: 'Updated content',
          );
          when(mockInformationRepository.update(any))
              .thenAnswer((_) async => testInfo);
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => [testInfo]);
          return informationBloc;
        },
        act: (bloc) => bloc.add(UpdateInformation(
          id: 'test-id',
          content: 'Updated content',
          tagNames: ['flutter'],
        )),
        expect: () => [
          InformationSaving(),
          InformationSaved(),
          isA<InformationLoaded>(),
        ],
        verify: (_) {
          verify(mockInformationRepository.update(any)).called(1);
          verify(mockInformationRepository.getAll()).called(1);
        },
      );

      blocTest<InformationBloc, InformationState>(
        'emits [InformationSaving, InformationError] when UpdateInformation fails',
        build: () {
          when(mockInformationRepository.update(any))
              .thenThrow(Exception('Update failed'));
          return informationBloc;
        },
        act: (bloc) => bloc.add(UpdateInformation(
          id: 'test-id',
          content: 'Updated content',
          tagNames: [],
        )),
        expect: () => [
          InformationSaving(),
          isA<InformationError>()
              .having((state) => state.message, 'error message', contains('Update failed')),
        ],
      );
    });

    group('DeleteInformation', () {
      blocTest<InformationBloc, InformationState>(
        'emits [InformationLoading, InformationLoaded] when DeleteInformation is successful',
        build: () {
          when(mockInformationRepository.delete('test-id'))
              .thenAnswer((_) async {});
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => []);
          return informationBloc;
        },
        act: (bloc) => bloc.add(DeleteInformation('test-id')),
        expect: () => [
          InformationLoading(),
          isA<InformationLoaded>()
              .having((state) => state.information.length, 'information length', 0),
        ],
        verify: (_) {
          verify(mockInformationRepository.delete('test-id')).called(1);
          verify(mockInformationRepository.getAll()).called(1);
        },
      );

      blocTest<InformationBloc, InformationState>(
        'emits [InformationLoading, InformationError] when DeleteInformation fails',
        build: () {
          when(mockInformationRepository.delete('test-id'))
              .thenThrow(Exception('Delete failed'));
          return informationBloc;
        },
        act: (bloc) => bloc.add(DeleteInformation('test-id')),
        expect: () => [
          InformationLoading(),
          isA<InformationError>()
              .having((state) => state.message, 'error message', contains('Delete failed')),
        ],
      );
    });

    group('SearchInformation', () {
      blocTest<InformationBloc, InformationState>(
        'emits [InformationLoading, InformationLoaded] when SearchInformation is successful',
        build: () {
          final testInformation = TestDataFactory.createInformationList(2);
          when(mockInformationRepository.searchByTags(['flutter']))
              .thenAnswer((_) async => testInformation);
          return informationBloc;
        },
        act: (bloc) => bloc.add(SearchInformation(['flutter'])),
        expect: () => [
          InformationLoading(),
          isA<InformationLoaded>()
              .having((state) => state.information.length, 'information length', 2),
        ],
        verify: (_) {
          verify(mockInformationRepository.searchByTags(['flutter'])).called(1);
        },
      );

      blocTest<InformationBloc, InformationState>(
        'emits [InformationLoading, InformationLoaded] with empty results when no matches found',
        build: () {
          when(mockInformationRepository.searchByTags(['nonexistent']))
              .thenAnswer((_) async => []);
          return informationBloc;
        },
        act: (bloc) => bloc.add(SearchInformation(['nonexistent'])),
        expect: () => [
          InformationLoading(),
          isA<InformationLoaded>()
              .having((state) => state.information.length, 'information length', 0),
        ],
      );

      blocTest<InformationBloc, InformationState>(
        'loads all information when search query is empty',
        build: () {
          final testInformation = TestDataFactory.createInformationList(3);
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => testInformation);
          return informationBloc;
        },
        act: (bloc) => bloc.add(SearchInformation([])),
        expect: () => [
          InformationLoading(),
          isA<InformationLoaded>()
              .having((state) => state.information.length, 'information length', 3),
        ],
        verify: (_) {
          verify(mockInformationRepository.getAll()).called(1);
          verifyNever(mockInformationRepository.searchByTags(any));
        },
      );
    });

    group('ClearInformation', () {
      blocTest<InformationBloc, InformationState>(
        'emits [InformationInitial] when ClearInformation is called',
        build: () => informationBloc,
        act: (bloc) => bloc.add(ClearInformation()),
        expect: () => [InformationInitial()],
      );
    });

    group('State transitions', () {
      blocTest<InformationBloc, InformationState>(
        'handles multiple rapid events correctly',
        build: () {
          final testInfo = TestDataFactory.createInformation();
          when(mockInformationRepository.create(any))
              .thenAnswer((_) async => testInfo);
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => [testInfo]);
          return informationBloc;
        },
        act: (bloc) {
          bloc.add(CreateInformation(content: 'Test 1', tagNames: []));
          bloc.add(CreateInformation(content: 'Test 2', tagNames: []));
          bloc.add(LoadInformation());
        },
        expect: () => [
          InformationSaving(),
          InformationSaved(),
          isA<InformationLoaded>(),
          InformationSaving(),
          InformationSaved(),
          isA<InformationLoaded>(),
          InformationLoading(),
          isA<InformationLoaded>(),
        ],
      );

      blocTest<InformationBloc, InformationState>(
        'handles error recovery correctly',
        build: () {
          when(mockInformationRepository.create(any))
              .thenThrow(Exception('First error'))
              .thenAnswer((_) async => TestDataFactory.createInformation());
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => [TestDataFactory.createInformation()]);
          return informationBloc;
        },
        act: (bloc) {
          bloc.add(CreateInformation(content: 'Test', tagNames: []));
          bloc.add(CreateInformation(content: 'Test 2', tagNames: []));
        },
        expect: () => [
          InformationSaving(),
          isA<InformationError>(),
          InformationSaving(),
          InformationSaved(),
          isA<InformationLoaded>(),
        ],
      );
    });

    group('Edge cases', () {
      blocTest<InformationBloc, InformationState>(
        'handles very long content correctly',
        build: () {
          final longContent = 'A' * 10000;
          final testInfo = TestDataFactory.createInformation(content: longContent);
          when(mockInformationRepository.create(any))
              .thenAnswer((_) async => testInfo);
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => [testInfo]);
          return informationBloc;
        },
        act: (bloc) => bloc.add(CreateInformation(
          content: 'A' * 10000,
          tagNames: [],
        )),
        expect: () => [
          InformationSaving(),
          InformationSaved(),
          isA<InformationLoaded>(),
        ],
      );

      blocTest<InformationBloc, InformationState>(
        'handles unicode content correctly',
        build: () {
          const unicodeContent = 'Unicode test 🎉💻📱🚀 with emojis';
          final testInfo = TestDataFactory.createInformation(content: unicodeContent);
          when(mockInformationRepository.create(any))
              .thenAnswer((_) async => testInfo);
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => [testInfo]);
          return informationBloc;
        },
        act: (bloc) => bloc.add(CreateInformation(
          content: unicodeContent,
          tagNames: [],
        )),
        expect: () => [
          InformationSaving(),
          InformationSaved(),
          isA<InformationLoaded>(),
        ],
      );

      blocTest<InformationBloc, InformationState>(
        'handles large number of tags correctly',
        build: () {
          final manyTags = List.generate(50, (index) => 'tag$index');
          final testInfo = TestDataFactory.createInformation();
          when(mockInformationRepository.create(any))
              .thenAnswer((_) async => testInfo);
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => [testInfo]);
          return informationBloc;
        },
        act: (bloc) => bloc.add(CreateInformation(
          content: 'Test with many tags',
          tagNames: List.generate(50, (index) => 'tag$index'),
        )),
        expect: () => [
          InformationSaving(),
          InformationSaved(),
          isA<InformationLoaded>(),
        ],
      );
    });

    group('Performance considerations', () {
      blocTest<InformationBloc, InformationState>(
        'handles large dataset loading efficiently',
        build: () {
          final largeDataset = TestDataFactory.createInformationList(1000);
          when(mockInformationRepository.getAll())
              .thenAnswer((_) async => largeDataset);
          return informationBloc;
        },
        act: (bloc) => bloc.add(LoadInformation()),
        expect: () => [
          InformationLoading(),
          isA<InformationLoaded>()
              .having((state) => state.information.length, 'information length', 1000),
        ],
        verify: (_) {
          verify(mockInformationRepository.getAll()).called(1);
        },
      );
    });
  });
}