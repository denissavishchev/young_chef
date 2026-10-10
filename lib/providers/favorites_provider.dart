import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/answer_model.dart';

class FavoriteRecipe {
  const FavoriteRecipe({
    required this.id,
    required this.recipe,
    this.photoPath,
  });

  final String id;
  final RecipeResponse recipe;
  final String? photoPath;
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
          photoPath: (_box.get(key) as Map)['photoPath'] as String?,
        ),
    ];
  }

  /// Copies [photo] into the app's documents folder so it outlives the
  /// picker's temporary file.
  Future<String> _storePhoto(String id, XFile photo) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/favorites');
    await folder.create(recursive: true);
    final file = File('${folder.path}/$id.jpg');
    await file.writeAsBytes(await photo.readAsBytes());
    return file.path;
  }

  Future<String> add(RecipeResponse recipe, {XFile? photo}) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final map = recipe.toMap();
    if (photo != null) map['photoPath'] = await _storePhoto(id, photo);
    await _box.put(id, map);
    notifyListeners();
    return id;
  }

  Future<void> remove(String id) async {
    final path = (_box.get(id) as Map?)?['photoPath'] as String?;
    await _box.delete(id);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    notifyListeners();
  }
}
