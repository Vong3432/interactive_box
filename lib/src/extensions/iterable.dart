extension IterableDistinctExt<T> on Iterable<T> {
  Iterable<T> distinct() sync* {
    final visited = <T>{};
    for (final el in this) {
      if (visited.contains(el)) continue;
      yield el;
      visited.add(el);
    }
  }
}
