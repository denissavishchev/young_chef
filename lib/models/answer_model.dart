class RecipeResponse {
  final String recipeName;
  final List<String> ingredients;
  final String instructions;
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
      instructions: json['instructions'] ?? '',
      calories: json['calories']?.toString() ?? '',
      protein: json['protein']?.toString() ?? '',
      carbohydrates: json['carbohydrates']?.toString() ?? '',
      fat: json['fat']?.toString() ?? '',
      developerInfo: json['developerInfo']?.toString() ?? '',
    );
  }
}