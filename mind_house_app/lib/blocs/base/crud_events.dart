import 'base_event.dart';

abstract class CrudEvent extends BaseEvent {
  const CrudEvent();
}

class LoadAllEvent extends CrudEvent {
  const LoadAllEvent();
}

class LoadByIdEvent extends CrudEvent {
  final String id;

  const LoadByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateItemEvent<T> extends CrudEvent {
  final T item;

  const CreateItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateItemEvent<T> extends CrudEvent {
  final T item;

  const UpdateItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class DeleteItemEvent extends CrudEvent {
  final String id;

  const DeleteItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RefreshAllEvent extends CrudEvent {
  const RefreshAllEvent();
}

class SearchEvent extends CrudEvent {
  final String query;

  const SearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterEvent<T> extends CrudEvent {
  final T filter;

  const FilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}