import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/answer_model.dart';

class FavoriteRecipe {
  const FavoriteRecipe({required this.id, required this.recipe});

  final String id;
  final RecipeResponse recipe;
}

class FavoritesProvider extends ChangeNotifier {
  static const String boxName = 'favorites';

  Box get _box => Hive.box(boxName);

  /// Newest first (keys are creation timestamps).
  List<FavoriteRecipe> get favorites {
    final keys = _box.keys.cast<String>().toList()
      ..sort((a, b) => b.compareTo(a));
    return [
      for (final key in keys)
        FavoriteRecipe(
          id: key,
          recipe: RecipeResponse.fromMap(_box.get(key) as Map),
        ),
    ];
  }

  Future<String> add(RecipeResponse recipe) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _box.put(id, recipe.toMap());
    notifyListeners();
    return id;
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
