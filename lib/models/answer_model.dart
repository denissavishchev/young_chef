class RecipeResponse {
  final String recipeName;
  final List<String> ingredients;
  final List<String> instructions;
  final String calories;
  final String protein;
  final String carbohydrates;
  final String fat;
  final String developerInfo;
  final int cookingTime;
  final bool isVegan;

  RecipeResponse({
    required this.recipeName,
    required this.ingredients,
    required this.instructions,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.developerInfo,
    this.cookingTime = 0,
    this.isVegan = false,
  });

  /// [fallbackTime] and [fallbackVegan] are used when the model's
  /// `developerInfo` does not carry usable values.
  factory RecipeResponse.fromJson(
    Map<String, dynamic> json, {
    int fallbackTime = 0,
    bool fallbackVegan = false,
  }) {
    final info = json['developerInfo'];
    final infoMap = info is Map ? info : const {};
    final timeMatch = RegExp(r'\d+').firstMatch('${infoMap['cookingTime']}');
    final vegan = infoMap['isVegan'];
    return RecipeResponse(
      cookingTime: int.tryParse(timeMatch?.group(0) ?? '') ?? fallbackTime,
      isVegan: vegan is bool ? vegan : fallbackVegan,
      recipeName: json['recipeName'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: _parseInstructions(json['instructions']),
      calories: json['calories']?.toString() ?? '',
      protein: json['protein']?.toString() ?? '',
      carbohydrates: json['carbohydrates']?.toString() ?? '',
      fat: json['fat']?.toString() ?? '',
      developerInfo: json['developerInfo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'recipeName': recipeName,
        'ingredients': ingredients,
        'instructions': instructions,
        'calories': calories,
        'protein': protein,
        'carbohydrates': carbohydrates,
        'fat': fat,
        'developerInfo': developerInfo,
        'cookingTime': cookingTime,
        'isVegan': isVegan,
      };

  factory RecipeResponse.fromMap(Map<dynamic, dynamic> map) {
    return RecipeResponse(
      recipeName: map['recipeName'] as String? ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? const []),
      instructions: List<String>.from(map['instructions'] ?? const []),
      calories: map['calories'] as String? ?? '',
      protein: map['protein'] as String? ?? '',
      carbohydrates: map['carbohydrates'] as String? ?? '',
      fat: map['fat'] as String? ?? '',
      developerInfo: map['developerInfo'] as String? ?? '',
      cookingTime: map['cookingTime'] as int? ?? 0,
      isVegan: map['isVegan'] as bool? ?? false,
    );
  }

  static List<String> _parseInstructions(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      final numbered = value
          .split(RegExp(r'\n?\s*\d+[\.\)]\s+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (numbered.length > 1) return numbered;
      final lines = value
          .split(RegExp(r'\n+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (lines.isNotEmpty) return lines;
    }
    return [];
  }
}
