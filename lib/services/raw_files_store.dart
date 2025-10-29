// GENERATED: In-memory store for raw uploaded files (.txt)
import 'dart:typed_data';

class RawFilesStore {
  static final Map<String, Uint8List> _files = {};

  static void put(String key, Uint8List bytes) {
    _files[key] = bytes;
  }

  static Uint8List? get(String key) {
    return _files[key];
  }

  static bool has(String key) => _files.containsKey(key);
}
