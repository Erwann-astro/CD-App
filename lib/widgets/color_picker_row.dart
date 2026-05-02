import 'package:flutter/material.dart';

class ColorPickerRow extends StatelessWidget {
  static const List<Color> palette = [
    Color(0xFF2196F3), // Bleu
    Color(0xFF4CAF50), // Vert
    Color(0xFFF44336), // Rouge
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Violet
    Color(0xFF009688), // Teal
    Color(0xFFE91E63), // Rose
    Color(0xFFFFEB3B), // Jaune
    Color(0xFF795548), // Marron
    Color(0xFF607D8B), // Gris bleu
  ];

  final int selectedValue;
  final ValueChanged<int> onChanged;

  const ColorPickerRow({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: palette.map((color) {
        final isSelected = color.value == selectedValue;
        return GestureDetector(
          onTap: () => onChanged(color.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 3,
                    )
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
