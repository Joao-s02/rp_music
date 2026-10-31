/// Bounded session-only presentation state. Never serializes searches or URLs.
class ExtensionViewCache {
  final _entries =
      <
        String,
        ({Object owner, int revision, DateTime expires, Object value})
      >{};

  T? read<T>(String id, Object? owner, int revision) {
    final entry = _entries.remove(id);
    if (entry == null ||
        !identical(entry.owner, owner) ||
        entry.revision != revision ||
        DateTime.now().isAfter(entry.expires)) {
      return null;
    }
    _entries[id] = entry;
    return entry.value is T ? entry.value as T : null;
  }

  void save(String id, Object? owner, int revision, Object value) {
    if (owner == null) return;
    _entries.remove(id);
    _entries[id] = (
      owner: owner,
      revision: revision,
      expires: DateTime.now().add(const Duration(minutes: 30)),
      value: value,
    );
    while (_entries.length > 8) {
      _entries.remove(_entries.keys.first);
    }
  }

  void clear() => _entries.clear();
}
