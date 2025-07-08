import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_house_app/blocs/base/base.dart';

class MockRepository {
  bool shouldThrowError = false;
  String errorMessage = 'Mock repository error';

  void reset() {
    shouldThrowError = false;
    errorMessage = 'Mock repository error';
  }

  void setError(String message) {
    shouldThrowError = true;
    errorMessage = message;
  }

  void checkError() {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
  }
}

class TestCrudBloc extends CrudBloc<String> {
  final MockRepository _mockRepository;
  final List<String> _items = ['item1', 'item2', 'item3'];

  TestCrudBloc(this._mockRepository) : super(loggerName: 'TestCrudBloc');

  @override
  Future<List<String>> getAllItems() async {
    _mockRepository.checkError();
    await Future.delayed(const Duration(milliseconds: 50));
    return List.from(_items);
  }

  @override
  Future<String?> getItemById(String id) async {
    _mockRepository.checkError();
    await Future.delayed(const Duration(milliseconds: 50));
    return _items.contains(id) ? id : null;
  }

  @override
  Future<String> createItem(String item) async {
    _mockRepository.checkError();
    await Future.delayed(const Duration(milliseconds: 50));
    _items.add(item);
    return item;
  }

  @override
  Future<String> updateItem(String item) async {
    _mockRepository.checkError();
    await Future.delayed(const Duration(milliseconds: 50));
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    _mockRepository.checkError();
    await Future.delayed(const Duration(milliseconds: 50));
    _items.remove(id);
  }

  @override
  Future<List<String>> searchItems(String query) async {
    _mockRepository.checkError();
    await Future.delayed(const Duration(milliseconds: 50));
    return _items.where((item) => item.contains(query)).toList();
  }

  @override
  Future<List<String>> filterItems(dynamic filter) async {
    _mockRepository.checkError();
    await Future.delayed(const Duration(milliseconds: 50));
    if (filter is String) {
      return _items.where((item) => item.startsWith(filter)).toList();
    }
    return _items;
  }
}