class Recipe {
  final String id;
  final String name;
  final String category;
  final String image;
  final String cookTime;
  final String difficulty;
  final String description;
  final List<String> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.cookTime,
    required this.difficulty,
    required this.description,
    required this.ingredients,
  });

  // Copy with method untuk update recipe
  Recipe copyWith({
    String? id,
    String? name,
    String? category,
    String? image,
    String? cookTime,
    String? difficulty,
    String? description,
    List<String>? ingredients,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      image: image ?? this.image,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}