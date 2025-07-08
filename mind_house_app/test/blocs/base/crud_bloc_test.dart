import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/blocs/base/base.dart';
import 'test_helpers.dart';

void main() {
  group('CrudBloc Tests', () {
    late MockRepository mockRepository;
    late TestCrudBloc crudBloc;

    setUp(() {
      mockRepository = MockRepository();
      crudBloc = TestCrudBloc(mockRepository);
    });

    tearDown(() {
      crudBloc.close();
    });

    group('Initial State', () {
      test('initial state should be CrudInitialState', () {
        expect(crudBloc.state, isA<CrudInitialState>());
      });
    });

    group('LoadAllEvent', () {
      blocTest<TestCrudBloc, CrudState>(
        'emits [CrudLoadingState, CrudLoadedState] when LoadAllEvent is added',
        build: () => TestCrudBloc(MockRepository()),
        act: (bloc) => bloc.add(const LoadAllEvent()),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const CrudLoadingState(),
          isA<CrudLoadedState<String>>(),
        ],
      );

      blocTest<TestCrudBloc, CrudState>(
        'emits [CrudLoadingState, CrudErrorState] when repository throws error',
        build: () {
          final repo = MockRepository();
          repo.setError('Failed to load all items');
          return TestCrudBloc(repo);
        },
        act: (bloc) => bloc.add(const LoadAllEvent()),
        expect: () => [
          const CrudLoadingState(),
          isA<CrudErrorState>(),
        ],
      );
    });

    group('LoadByIdEvent', () {
      blocTest<TestCrudBloc, CrudState>(
        'emits [CrudLoadingState, CrudItemLoadedState] when item exists',
        build: () => TestCrudBloc(MockRepository()),
        act: (bloc) => bloc.add(const LoadByIdEvent('item1')),
        expect: () => [
          const CrudLoadingState(),
          isA<CrudItemLoadedState<String>>(),
        ],
      );

      blocTest<TestCrudBloc, CrudState>(
        'emits [CrudLoadingState, CrudErrorState] when item does not exist',
        build: () => TestCrudBloc(MockRepository()),
        act: (bloc) => bloc.add(const LoadByIdEvent('nonexistent')),
        expect: () => [
          const CrudLoadingState(),
          isA<CrudErrorState>(),
        ],
      );
    });

    group('CreateItemEvent', () {
      blocTest<TestCrudBloc, CrudState>(
        'emits [CrudCreatingState, CrudCreatedState] when item is created successfully',
        build: () => TestCrudBloc(MockRepository()),
        act: (bloc) => bloc.add(const CreateItemEvent<String>('newItem')),
        expect: () => [
          const CrudCreatingState(),
          isA<CrudCreatedState<String>>(),
        ],
      );

      blocTest<TestCrudBloc, CrudState>(
        'emits [CrudCreatingState, CrudErrorState] when creation fails',
        build: () {
          final repo = MockRepository();
          repo.setError('Failed to create item');
          return TestCrudBloc(repo);
        },
        act: (bloc) => bloc.add(const CreateItemEvent<String>('newItem')),
        expect: () => [
          const CrudCreatingState(),
          isA<CrudErrorState>(),
        ],
      );
    });

    group('UpdateItemEvent', () {
      blocTest<TestCrudBloc, CrudState>(
        'emits [CrudUpdatingState, CrudUpdatedState] when item is updated successfully',
        build: () => TestCrudBloc(MockRepository()),
        act: (bloc) => bloc.add(const UpdateItemEvent<String>('updatedItem')),
        expect: () => [
          const CrudUpdatingState(),
          isA<CrudUpdatedState<String>>(),
        ],
      );
    });

    group('DeleteItemEvent', () {
      blocTest<TestCrudBloc, CrudState>(
        'emits [CrudDeletingState, CrudDeletedState] when item is deleted successfully',
        build: () => TestCrudBloc(MockRepository()),
        act: (bloc) => bloc.add(const DeleteItemEvent('item1')),
        expect: () => [
          const CrudDeletingState(),
          isA<CrudDeletedState>(),
        ],
      );
    });

    group('SearchEvent', () {
      blocTest<TestCrudBloc, CrudState>(
        'emits [CrudSearchingState, CrudSearchResultsState] when search is performed',
        build: () => TestCrudBloc(MockRepository()),
        act: (bloc) => bloc.add(const SearchEvent('item')),
        expect: () => [
          const CrudSearchingState(),
          isA<CrudSearchResultsState<String>>(),
        ],
      );
    });

    group('FilterEvent', () {
      blocTest<TestCrudBloc, CrudState>(
        'emits [CrudLoadingState, CrudFilteredState] when filter is applied',
        build: () => TestCrudBloc(MockRepository()),
        act: (bloc) => bloc.add(const FilterEvent<String>('item')),
        expect: () => [
          const CrudLoadingState(),
          isA<CrudFilteredState<String>>(),
        ],
      );
    });

    group('RefreshAllEvent', () {
      test('triggers LoadAllEvent when RefreshAllEvent is added', () async {
        bool loadAllEventTriggered = false;
        
        crudBloc.stream.listen((state) {
          if (state is CrudLoadingState) {
            loadAllEventTriggered = true;
          }
        });

        crudBloc.add(const RefreshAllEvent());
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(loadAllEventTriggered, isTrue);
      });
    });

    group('State Helpers', () {
      test('isLoading should return false initially', () {
        expect(crudBloc.isLoading, isFalse);
      });

      test('hasError should return false initially', () {
        expect(crudBloc.hasError, isFalse);
      });

      test('isInitial should return true initially', () {
        expect(crudBloc.isInitial, isTrue);
      });
    });
  });
}