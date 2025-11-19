import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recipe_providers.dart';
import '../widgets/category_chip.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_list_item.dart';
import 'add_recipe_screen.dart';

class RecipeHomePage extends ConsumerStatefulWidget {
  const RecipeHomePage({super.key});

  @override
  ConsumerState<RecipeHomePage> createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends ConsumerState<RecipeHomePage> {
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryDark = Color(0xFFE65100);
  static const Color primaryMain = Color(0xFFFF6F00);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = ref.watch(filteredRecipesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final viewMode = ref.watch(viewModeProvider);
    final showOnlyFavorites = ref.watch(showOnlyFavoritesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 2,
        backgroundColor: primaryDark,
        title: const Text(
          'Katalog Resep Masakan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),

      // ===========================================================
      // ======================  BODY  ==============================
      // ===========================================================
      body: Column(
        children: [
          // ========== TOP TOOLBAR SECTION (GRID/LIST, FAVORITE, SEARCH) ==========
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryMain.withOpacity(0.15),
              border: const Border(
                bottom: BorderSide(color: Colors.black12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Cari resep...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10), 

                // -------- Grid/List Toggle --------
                Tooltip(
                  message: viewMode == ViewMode.grid ? 'Tampilan List' : 'Tampilan Grid',
                  child: GestureDetector(
                    onTap: () {
                      ref.read(viewModeProvider.notifier).state =
                          viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
                    },
                    child: Container(
                      height: 48, 
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryDark,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        viewMode == ViewMode.grid ? Icons.grid_view : Icons.list,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8), 

                // -------- Favorite Toggle Button --------
                Tooltip(
                  message: showOnlyFavorites ? 'Tampilkan Semua' : 'Tampilkan Favorit',
                  child: GestureDetector(
                    onTap: () {
                      ref.read(showOnlyFavoritesProvider.notifier).state =
                          !showOnlyFavorites;
                    },
                    child: Container(
                      height: 48, 
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: showOnlyFavorites
                            ? Colors.red.shade400
                            : Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ====================== CATEGORY FILTER SECTION ======================
          Container(
            height: 50,
            width: double.infinity,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                CategoryChip(
                  label: 'Semua',
                  isSelected: selectedCategory == 'Semua',
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = 'Semua';
                  },
                ),
                CategoryChip(
                  label: 'Indonesian',
                  isSelected: selectedCategory == 'Indonesian',
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state =
                        'Indonesian';
                  },
                ),
                CategoryChip(
                  label: 'Western',
                  isSelected: selectedCategory == 'Western',
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state =
                        'Western';
                  },
                ),
                CategoryChip(
                  label: 'Dessert',
                  isSelected: selectedCategory == 'Dessert',
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state =
                        'Dessert';
                  },
                ),
              ],
            ),
          ),

          // ====================== FAVORITE ALERT ======================
          if (showOnlyFavorites)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Resep favorit',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ref.read(showOnlyFavoritesProvider.notifier).state =
                          false;
                    },
                    child: const Text(
                      'Tampilkan Semua',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // ====================== MAIN CONTENT ======================
          Expanded(
            child: filteredRecipes.isEmpty
                ? _buildEmptyState(showOnlyFavorites)
                : viewMode == ViewMode.grid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRecipes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          return RecipeCard(recipe: filteredRecipes[index]);
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          return RecipeListItem(
                            recipe: filteredRecipes[index],
                          );
                        },
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
      onPressed: () {
      showDialog(
      context: context,
      builder: (context) => const AddRecipeDialog(),
    );
  },
      child: const Icon(Icons.add), 
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
      ),
    );
  }

  // ====================== EMPTY STATE WIDGET ======================
  Widget _buildEmptyState(bool showFav) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showFav ? Icons.favorite_border : Icons.search_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            showFav ? 'Belum ada resep favorit' : 'Resep tidak ditemukan',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}