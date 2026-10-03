class RecipeResponse {
  final String recipeName;
  final List<String> ingredients;
  final List<String> instructions;
  final String calories;
  final String protein;
  final String carbohydrates;
  final String fat;
  final String developerInfo;

  RecipeResponse({
    required this.recipeName,
    required this.ingredients,
    required this.instructions,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.developerInfo,
  });

  factory RecipeResponse.fromJson(Map<String, dynamic> json) {
    return RecipeResponse(
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
