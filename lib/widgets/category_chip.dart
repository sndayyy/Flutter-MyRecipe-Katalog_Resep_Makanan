import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  // Definisikan warna yang digunakan
  static const Color primaryColor = Color(0xFFFF6F00); // Oranye utama

  @override
  Widget build(BuildContext context) {
    return Padding( 
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer( 
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: 8,    
          ),
          decoration: BoxDecoration(
            // 1. Latar Belakang Penuh 
            color: isSelected ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(25), 
            
            // 2. Bayangan/Elevasi 
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
            
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87, 
            ),
          ),
        ),
      ),
    );
  }
}