import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/blocs/base/base.dart';
import 'test_helpers.dart';

void main() {
  group('Basic CRUD BLoC Tests', () {
    late MockRepository mockRepository;

    setUp(() {
      mockRepository = MockRepository();
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
        wait: const Duration(milliseconds: 100),
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
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const CrudCreatingState(),
          isA<CrudCreatedState<String>>(),
        ],
      );
    });

    group('State Verification', () {
      test('should have correct initial state and helpers', () {
        final bloc = TestCrudBloc(mockRepository);
        
        expect(bloc.state, isA<CrudInitialState>());
        expect(bloc.isInitial, isTrue);
        expect(bloc.isLoading, isFalse);
        expect(bloc.hasError, isFalse);
        
        bloc.close();
      });
    });
  });
}