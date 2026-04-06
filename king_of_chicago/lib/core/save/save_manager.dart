import 'dart:convert';

import 'package:hive/hive.dart';

import 'save_data.dart';

/// Hive-based persistence manager for save data.
///
/// Provides static methods to save, load, check, and delete game saves
/// across multiple slots. Each slot stores a JSON-encoded string in a
/// Hive box named 'saves'.
class SaveManager {
  static const String _boxName = 'saves';

  static String _slotKey(int slot) => 'save_slot_$slot';

  /// Saves [data] to the given [slot] (default 0).
  ///
  /// Serializes the [SaveData] to JSON and stores it as a string
  /// in the Hive 'saves' box.
  static Future<void> save(SaveData data, {int slot = 0}) async {
    final box = await Hive.openBox<String>(_boxName);
    final jsonString = jsonEncode(data.toJson());
    await box.put(_slotKey(slot), jsonString);
  }

  /// Loads save data from the given [slot] (default 0).
  ///
  /// Returns `null` if no save exists in the slot.
  static Future<SaveData?> load({int slot = 0}) async {
    final box = await Hive.openBox<String>(_boxName);
    final jsonString = box.get(_slotKey(slot));
    if (jsonString == null) {
      return null;
    }
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return SaveData.fromJson(json);
  }

  /// Returns `true` if a save exists in the given [slot] (default 0).
  static Future<bool> hasSave({int slot = 0}) async {
    final box = await Hive.openBox<String>(_boxName);
    return box.containsKey(_slotKey(slot));
  }

  /// Deletes the save in the given [slot] (default 0).
  static Future<void> deleteSave({int slot = 0}) async {
    final box = await Hive.openBox<String>(_boxName);
    await box.delete(_slotKey(slot));
  }
}
