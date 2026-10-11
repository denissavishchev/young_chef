/// AI-generated facts about a single food product.
class ProductInfo {
  ProductInfo({
    required this.name,
    required this.about,
    required this.pros,
    required this.cons,
    required this.usefulFor,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
  });

  final String name;
  final String about;
  final List<String> pros;
  final List<String> cons;
  final String usefulFor;
  final String calories;
  final String protein;
  final String carbohydrates;
  final String fat;
  final String fiber;

  static List<String> _list(Object? value) =>
      value is List ? value.map((e) => e.toString()).toList() : <String>[];

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    final per100 = (json['per100g'] as Map?)?.cast<String, dynamic>() ?? {};
    return ProductInfo(
      name: (json['name'] ?? '').toString(),
      about: (json['about'] ?? '').toString(),
      pros: _list(json['pros']),
      cons: _list(json['cons']),
      usefulFor: (json['usefulFor'] ?? '').toString(),
      calories: (per100['calories'] ?? '-').toString(),
      protein: (per100['protein'] ?? '-').toString(),
      carbohydrates: (per100['carbohydrates'] ?? '-').toString(),
      fat: (per100['fat'] ?? '-').toString(),
      fiber: (per100['fiber'] ?? '-').toString(),
    );
  }
}
