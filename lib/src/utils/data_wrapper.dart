/// Small data wrapper, that allow data to be null when himself isn't.
/// Allow to properly handle loading state when data may be null.
class DataWrapper<T> {
  const DataWrapper(this.data);

  final T data;
}
