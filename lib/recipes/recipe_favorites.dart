import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'recipe_catalog.dart';

/// One bounded local collection shared by the gallery and playground.
class RecipeFavorites extends ValueNotifier<Set<String>> {
  RecipeFavorites() : super({});
  static final shared = RecipeFavorites();
  static const storageKey = 'nib_ember_favorites_v1';
  SharedPreferences? _storage;
  Future<void>? _loading;
  bool persistentAvailable = false;

  Future<void> load() => _loading ??= _load();
  Future<void> _load() async {
    try {
      _storage = await SharedPreferences.getInstance();
      persistentAvailable = true;
      value = {
        ...value,
        ...(_storage!.getStringList(storageKey) ?? <String>[]).where(
          (id) => recipeById(id) != null,
        ),
      };
    } catch (_) {
      persistentAvailable = false;
    }
  }

  Future<void> toggle(String id) async {
    if (recipeById(id) == null) return;
    await load();
    final next = {...value};
    next.contains(id) ? next.remove(id) : next.add(id);
    value = next;
    try {
      if (_storage != null) {
        persistentAvailable = await _storage!.setStringList(
          storageKey,
          next.toList()..sort(),
        );
      }
    } catch (_) {
      persistentAvailable = false;
    }
    notifyListeners();
  }
}
