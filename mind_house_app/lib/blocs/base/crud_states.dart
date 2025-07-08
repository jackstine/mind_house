import 'base_state.dart';

abstract class CrudState extends BaseState {
  const CrudState();
}

class CrudInitialState extends CrudState {
  const CrudInitialState();
}

class CrudLoadingState extends CrudState {
  const CrudLoadingState();
}

class CrudLoadedState<T> extends CrudState {
  final List<T> items;

  const CrudLoadedState(this.items);

  @override
  List<Object?> get props => [items];
}

class CrudItemLoadedState<T> extends CrudState {
  final T item;

  const CrudItemLoadedState(this.item);

  @override
  List<Object?> get props => [item];
}

class CrudErrorState extends CrudState {
  final String message;
  final Exception? exception;

  const CrudErrorState(this.message, {this.exception});

  @override
  List<Object?> get props => [message, exception];
}

class CrudCreatingState extends CrudState {
  const CrudCreatingState();
}

class CrudCreatedState<T> extends CrudState {
  final T item;

  const CrudCreatedState(this.item);

  @override
  List<Object?> get props => [item];
}

class CrudUpdatingState extends CrudState {
  const CrudUpdatingState();
}

class CrudUpdatedState<T> extends CrudState {
  final T item;

  const CrudUpdatedState(this.item);

  @override
  List<Object?> get props => [item];
}

class CrudDeletingState extends CrudState {
  const CrudDeletingState();
}

class CrudDeletedState extends CrudState {
  final String id;

  const CrudDeletedState(this.id);

  @override
  List<Object?> get props => [id];
}

class CrudSearchingState extends CrudState {
  const CrudSearchingState();
}

class CrudSearchResultsState<T> extends CrudState {
  final List<T> results;
  final String query;

  const CrudSearchResultsState(this.results, this.query);

  @override
  List<Object?> get props => [results, query];
}

class CrudFilteredState<T> extends CrudState {
  final List<T> filteredItems;
  final dynamic filter;

  const CrudFilteredState(this.filteredItems, this.filter);

  @override
  List<Object?> get props => [filteredItems, filter];
}