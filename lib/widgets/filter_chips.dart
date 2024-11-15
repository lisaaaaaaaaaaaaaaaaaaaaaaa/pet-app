import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FilterChips extends StatelessWidget {
  final List<FilterOption> options;
  final List<String> selectedValues;
  final Function(List<String>) onSelectionChanged;
  final bool allowMultiple;
  final ScrollController? scrollController;

  const FilterChips({
    Key? key,
    required this.options,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.allowMultiple = true,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = selectedValues.contains(option.value);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(option.label),
              onSelected: (selected) {
                List<String> newSelection;
                if (allowMultiple) {
                  newSelection = List.from(selectedValues);
                  if (selected) {
                    newSelection.add(option.value);
                  } else {
                    newSelection.remove(option.value);
                  }
                } else {
                  newSelection = selected ? [option.value] : [];
                }
                onSelectionChanged(newSelection);
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.cardColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterOption {
  final String label;
  final String value;
  final IconData? icon;

  const FilterOption({
    required this.label,
    required this.value,
    this.icon,
  });
}
