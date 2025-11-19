import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../providers/recipe_providers.dart';

class AddRecipeDialog extends ConsumerStatefulWidget {
  final Recipe? recipe;

  const AddRecipeDialog({super.key, this.recipe});

  @override
  ConsumerState<AddRecipeDialog> createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends ConsumerState<AddRecipeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();

  String _selectedCategory = 'Indonesian';
  String _selectedDifficulty = 'Mudah';
  String _selectedEmoji = '🍳';

  final List<String> _categories = ['Indonesian', 'Western', 'Dessert'];
  final List<String> _difficulties = ['Mudah', 'Sedang', 'Sulit'];

  // Tambahan ikon makanan baru!
  final List<String> _emojis = [
    '🍳',
    '🍝',
    '🍖',
    '🥞',
    '🍲',
    '🥗',
    '🍰',
    '🥙',
    '🍔',
    '🍕',
    '🍜',
    '🍱',
    '🥘',
    '🍛',
    '🍣',
    '🥟',
    '🌮',
    '🌯',
    '🥪',
    '🍩',
    '🧁',
    '🍪',
    '🥧',
    '🍦',
    '🥓',
    '🍗',
    '🍤',
    '🦐',
    '🦞',
    '🍢',
    '🍡',
    '🥮',
  ];

  static const Color primaryDark = Color(0xFFE65100);
  static const Color primaryMain = Color(0xFFFF6F00);

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      // Ambil hanya bagian angka dari cookTime saat Edit Mode
      final cookTimeParts = widget.recipe!.cookTime.split(' ');
      _cookTimeController.text = cookTimeParts.isNotEmpty && cookTimeParts.first.isNotEmpty
          ? cookTimeParts.first
          : '';

      _descriptionController.text = widget.recipe!.description;
      _ingredientsController.text = widget.recipe!.ingredients.join(', ');
      _selectedCategory = widget.recipe!.category;
      _selectedDifficulty = widget.recipe!.difficulty;
      _selectedEmoji = widget.recipe!.image;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cookTimeController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final recipes = ref.read(recipesProvider);

      final ingredientsList = _ingredientsController.text
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Logika Baru untuk Waktu Memasak
      // Pastikan input adalah angka, lalu tambahkan ' menit'
      final rawCookTime = _cookTimeController.text.trim();
      final cookTime = rawCookTime.isNotEmpty
          ? '$rawCookTime menit'
          : '0 menit'; // Pastikan ada nilai default

      if (widget.recipe != null) {
        // Edit mode
        final updatedRecipe = widget.recipe!.copyWith(
          name: _nameController.text,
          category: _selectedCategory,
          image: _selectedEmoji,
          cookTime: cookTime, // Menggunakan variabel cookTime yang sudah diformat
          difficulty: _selectedDifficulty,
          description: _descriptionController.text,
          ingredients: ingredientsList,
        );

        final updatedRecipes = recipes.map((r) {
          return r.id == updatedRecipe.id ? updatedRecipe : r;
        }).toList();

        ref.read(recipesProvider.notifier).state = updatedRecipes;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Resep berhasil diperbarui!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Add mode
        // Asumsi Recipe id dihitung berdasarkan panjang list. Ini mungkin tidak ideal untuk aplikasi nyata,
        // tapi sesuai dengan implementasi Anda.
        final newId = (recipes.length + 1).toString();

        final newRecipe = Recipe(
          id: newId,
          name: _nameController.text,
          category: _selectedCategory,
          image: _selectedEmoji,
          cookTime: cookTime, // Menggunakan variabel cookTime yang sudah diformat
          difficulty: _selectedDifficulty,
          description: _descriptionController.text,
          ingredients: ingredientsList,
        );

        ref.read(recipesProvider.notifier).state = [...recipes, newRecipe];

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Resep berhasil ditambahkan!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- Widget Kustom untuk Segmented Chip Button ---
  Widget _buildChipSelector({
    required String label,
    required List<String> options,
    required String selectedValue,
    required ValueSetter<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: options.map((item) {
            final isSelected = item == selectedValue;
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              selectedColor: primaryMain.withOpacity(0.1),
              onSelected: (selected) {
                if (selected) onSelected(item);
              },
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: isSelected ? primaryDark : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? primaryDark : Colors.grey.shade300,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.recipe != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 750,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditMode ? Icons.edit : Icons.add_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditMode ? 'Edit Resep' : 'Tambah Resep',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Emoji Selector
                    const Text(
                      'Pilih Icon Resep',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white, // Latar belakang putih
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        scrollDirection: Axis.horizontal,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: _emojis.length,
                        itemBuilder: (context, index) {
                          final emoji = _emojis[index];
                          final isSelected = emoji == _selectedEmoji;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedEmoji = emoji;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryMain.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryDark
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recipe Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Resep',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.restaurant_menu),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama resep tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildChipSelector(
                      label: 'Kategori',
                      options: _categories,
                      selectedValue: _selectedCategory,
                      onSelected: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildChipSelector(
                      label: 'Tingkat Kesulitan',
                      options: _difficulties,
                      selectedValue: _selectedDifficulty,
                      onSelected: (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Cook Time (Diubah untuk input angka)
                    TextFormField(
                      controller: _cookTimeController,
                      // HANYA MENGIZINKAN INPUT ANGKA
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Waktu Memasak (dalam menit, contoh: 30)',
                        suffixText: 'menit', // Menampilkan 'menit' sebagai suffix
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.access_time),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Waktu memasak tidak boleh kosong';
                        }
                        // Validasi sederhana: pastikan hanya mengandung digit
                        if (int.tryParse(value) == null) {
                          return 'Masukkan angka yang valid untuk waktu memasak';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        isDense: true,
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ingredients
                    TextFormField(
                      controller: _ingredientsController,
                      decoration: InputDecoration(
                        labelText: 'Bahan-bahan',
                        hintText: 'Pisahkan dengan koma atau enter',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.list_alt),
                        isDense: true,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bahan-bahan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4, // Menambah elevasi tombol
                      ),
                      child: Text(
                        isEditMode ? 'Perbarui Resep' : 'Simpan Resep',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}