import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/blocs/base/base.dart';
import 'test_helpers.dart';

void main() {
  group('Simple BLoC Tests', () {
    test('TestCrudBloc should initialize with CrudInitialState', () {
      final mockRepository = MockRepository();
      final bloc = TestCrudBloc(mockRepository);
      
      expect(bloc.state, isA<CrudInitialState>());
      expect(bloc.isInitial, isTrue);
      expect(bloc.isLoading, isFalse);
      expect(bloc.hasError, isFalse);
      
      bloc.close();
    });

    test('Base state types should work correctly', () {
      const initialState = CrudInitialState();
      const loadingState = CrudLoadingState();
      const errorState = CrudErrorState('Test error');
      
      expect(initialState, isA<CrudState>());
      expect(loadingState, isA<CrudState>());
      expect(errorState, isA<CrudState>());
    });
  });
}