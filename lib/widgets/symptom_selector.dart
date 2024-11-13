import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SymptomSelector extends StatefulWidget {
  final List<Symptom> symptoms;
  final List<String> selectedSymptoms;
  final ValueChanged<List<String>> onChanged;
  final String? title;
  final String? subtitle;
  final bool showCategories;
  final bool multiSelect;
  final bool showSearch;
  final bool isLoading;

  const SymptomSelector({
    Key? key,
    required this.symptoms,
    required this.selectedSymptoms,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.showCategories = true,
    this.multiSelect = true,
    this.showSearch = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<SymptomSelector> createState() => _SymptomSelectorState();
}

class _SymptomSelectorState extends State<SymptomSelector> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Symptom> get filteredSymptoms {
    return widget.symptoms.where((symptom) {
      final matchesSearch = symptom.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesCategory =
          !widget.showCategories || _selectedCategory == null || symptom.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Set<String> get categories {
    return widget.symptoms.map((s) => s.category).toSet();
  }

  void _toggleSymptom(String symptomName) {
    final List<String> updatedSelection = List.from(widget.selectedSymptoms);
    if (widget.multiSelect) {
      if (updatedSelection.contains(symptomName)) {
        updatedSelection.remove(symptomName);
      } else {
        updatedSelection.add(symptomName);
      }
    } else {
      updatedSelection
        ..clear()
        ..add(symptomName);
    }
    widget.onChanged(updatedSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
        ],
        if (widget.subtitle != null) ...[
          Text(
            widget.subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.neutralGrey,
                ),
          ),
          const SizedBox(height: 16),
        ],
        if (widget.showSearch)
          _buildSearchField(),
        if (widget.showCategories && categories.length > 1) ...[
          const SizedBox(height: 16),
          _buildCategoryChips(),
        ],
        const SizedBox(height: 16),
        if (widget.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (filteredSymptoms.isEmpty)
          Center(
            child: Text(
              'No symptoms found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.neutralGrey,
                  ),
            ),
          )
        else
          _buildSymptomGrid(),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search symptoms',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.neutralGrey.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.neutralGrey.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryGreen,
          ),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedCategory == null,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = null;
              });
            },
          ),
          const SizedBox(width: 8),
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSymptomGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filteredSymptoms.map((symptom) {
        final isSelected = widget.selectedSymptoms.contains(symptom.name);
        return ChoiceChip(
          label: Text(symptom.name),
          selected: isSelected,
          onSelected: (_) => _toggleSymptom(symptom.name),
          selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
          backgroundColor: AppTheme.lightBlue.withOpacity(0.1),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.neutralGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          avatar: symptom.icon != null
              ? Icon(
                  symptom.icon,
                  size: 18,
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.neutralGrey,
                )
              : null,
        );
      }).toList(),
    );
  }
}

class Symptom {
  final String name;
  final String category;
  final IconData? icon;
  final String? description;
  final List<String>? relatedSymptoms;
  final bool isEmergency;

  const Symptom({
    required this.name,
    required this.category,
    this.icon,
    this.description,
    this.relatedSymptoms,
    this.isEmergency = false,
  });
}