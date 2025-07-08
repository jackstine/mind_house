import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_bloc.dart';
import 'crud_events.dart';
import 'crud_states.dart';

abstract class CrudBloc<T> extends BaseBloc<CrudEvent, CrudState> {
  
  CrudBloc({String? loggerName}) : super(const CrudInitialState(), loggerName: loggerName) {
    on<LoadAllEvent>(_onLoadAll);
    on<LoadByIdEvent>(_onLoadById);
    on<CreateItemEvent<T>>(_onCreateItem);
    on<UpdateItemEvent<T>>(_onUpdateItem);
    on<DeleteItemEvent>(_onDeleteItem);
    on<RefreshAllEvent>(_onRefreshAll);
    on<SearchEvent>(_onSearch);
    on<FilterEvent>(_onFilter);
  }

  Future<List<T>> getAllItems();
  Future<T?> getItemById(String id);
  Future<T> createItem(T item);
  Future<T> updateItem(T item);
  Future<void> deleteItem(String id);
  Future<List<T>> searchItems(String query);
  Future<List<T>> filterItems(dynamic filter);

  Future<void> _onLoadAll(LoadAllEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final items = await getAllItems();
      emit(CrudLoadedState<T>(items));
      logInfo('Loaded ${items.length} items');
    } catch (e, stackTrace) {
      logError('Failed to load all items', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to load items: ${e.toString()}', exception: exception));
    }
  }

  Future<void> _onLoadById(LoadByIdEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final item = await getItemById(event.id);
      
      if (item != null) {
        emit(CrudItemLoadedState<T>(item));
        logInfo('Loaded item with id: ${event.id}');
      } else {
        emit(CrudErrorState('Item with id ${event.id} not found'));
      }
    } catch (e, stackTrace) {
      logError('Failed to load item by id: ${event.id}', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to load item: ${e.toString()}', exception: exception));
    }
  }

  Future<void> _onCreateItem(CreateItemEvent<T> event, Emitter<CrudState> emit) async {
    emit(const CrudCreatingState());
    try {
      final createdItem = await createItem(event.item);
      emit(CrudCreatedState<T>(createdItem));
      logInfo('Created new item');
    } catch (e, stackTrace) {
      logError('Failed to create item', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to create item: ${e.toString()}', exception: exception));
    }
  }

  Future<void> _onUpdateItem(UpdateItemEvent<T> event, Emitter<CrudState> emit) async {
    emit(const CrudUpdatingState());
    try {
      final updatedItem = await updateItem(event.item);
      emit(CrudUpdatedState<T>(updatedItem));
      logInfo('Updated item');
    } catch (e, stackTrace) {
      logError('Failed to update item', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to update item: ${e.toString()}', exception: exception));
    }
  }

  Future<void> _onDeleteItem(DeleteItemEvent event, Emitter<CrudState> emit) async {
    emit(const CrudDeletingState());
    try {
      await deleteItem(event.id);
      emit(CrudDeletedState(event.id));
      logInfo('Deleted item with id: ${event.id}');
    } catch (e, stackTrace) {
      logError('Failed to delete item with id: ${event.id}', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Failed to delete item: ${e.toString()}', exception: exception));
    }
  }

  Future<void> _onRefreshAll(RefreshAllEvent event, Emitter<CrudState> emit) async {
    add(const LoadAllEvent());
  }

  Future<void> _onSearch(SearchEvent event, Emitter<CrudState> emit) async {
    emit(const CrudSearchingState());
    try {
      final results = await searchItems(event.query);
      emit(CrudSearchResultsState<T>(results, event.query));
      logInfo('Search completed for query: "${event.query}", found ${results.length} results');
    } catch (e, stackTrace) {
      logError('Failed to search for query: "${event.query}"', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Search failed: ${e.toString()}', exception: exception));
    }
  }

  Future<void> _onFilter(FilterEvent event, Emitter<CrudState> emit) async {
    emit(const CrudLoadingState());
    try {
      final filteredItems = await filterItems(event.filter);
      emit(CrudFilteredState<T>(filteredItems, event.filter));
      logInfo('Filter applied, found ${filteredItems.length} items');
    } catch (e, stackTrace) {
      logError('Failed to apply filter', e, stackTrace);
      final exception = e is Exception ? e : Exception(e.toString());
      emit(CrudErrorState('Filter failed: ${e.toString()}', exception: exception));
    }
  }
}