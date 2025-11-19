import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../providers/recipe_providers.dart';
import '../screens/add_recipe_screen.dart';

class RecipeDetailSheet extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailSheet({super.key, required this.recipe});

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Hapus Resep?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${recipe.name}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Hapus resep
              final recipes = ref.read(recipesProvider);
              final updatedRecipes =
                  recipes.where((r) => r.id != recipe.id).toList();
              ref.read(recipesProvider.notifier).state = updatedRecipes;

              // Hapus dari favorit jika ada
              final favorites = ref.read(favoritesProvider);
              if (favorites.contains(recipe.id)) {
                final newFavorites = Set<String>.from(favorites);
                newFavorites.remove(recipe.id);
                ref.read(favoritesProvider.notifier).state = newFavorites;
              }

              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close bottom sheet

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Resep berhasil dihapus!'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _editRecipe(BuildContext context) {
    Navigator.pop(context); // Close bottom sheet first
    
    showDialog(
      context: context,
      builder: (context) => AddRecipeDialog(recipe: recipe),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(recipe.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Emoji
              Text(
                recipe.image,
                style: const TextStyle(fontSize: 80),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Recipe Name
              Text(
                recipe.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Info Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInfoChip(
                    Icons.access_time,
                    recipe.cookTime,
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.restaurant,
                    recipe.difficulty,
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0B2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    recipe.category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons (Edit, Delete, Favorite)
              Row(
                children: [
                  // Edit Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editRecipe(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE65100),
                        side: const BorderSide(color: Color(0xFFE65100)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Delete Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, ref),
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Favorite Button
                  Container(
                    decoration: BoxDecoration(
                      color: isFavorite ? Colors.red[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFavorite ? Colors.red : Colors.grey[300]!,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        final newFavorites = Set<String>.from(favorites);
                        if (isFavorite) {
                          newFavorites.remove(recipe.id);
                        } else {
                          newFavorites.add(recipe.id);
                        }
                        ref.read(favoritesProvider.notifier).state =
                            newFavorites;
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recipe.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Ingredients
              const Text(
                'Bahan-Bahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...recipe.ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFE65100),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}