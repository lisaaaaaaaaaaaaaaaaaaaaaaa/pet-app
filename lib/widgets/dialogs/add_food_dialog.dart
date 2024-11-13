import 'package:flutter/material.dart';
import '../common/custom_card.dart';
import '../common/loading_indicator.dart';
import '../custom_button.dart';
import '../../models/food_item.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class AddFoodDialog extends StatefulWidget {
  final String petId;
  final FoodItem? foodItem;

  const AddFoodDialog({
    Key? key,
    required this.petId,
    this.foodItem,
  }) : super(key: key);

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _ingredientsController = TextEditingController();
  
  String _selectedType = 'Dry Food';
  String _selectedUnit = 'cups';
  bool _isLoading = false;

  final List<String> _foodTypes = [
    'Dry Food',
    'Wet Food',
    'Treats',
    'Supplement',
    'Other'
  ];

  final List<String> _units = [
    'cups',
    'grams',
    'ounces',
    'pieces',
    'tablespoons'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.foodItem != null) {
      _initializeWithFood(widget.foodItem!);
    }
  }

  void _initializeWithFood(FoodItem food) {
    _nameController.text = food.name;
    _selectedType = food.type;
    _servingSizeController.text = food.servingSize.toString();
    _selectedUnit = food.unit;
    _caloriesController.text = food.calories.toString();
    _proteinController.text = food.protein?.toString() ?? '';
    _fatController.text = food.fat?.toString() ?? '';
    _fiberController.text = food.fiber?.toString() ?? '';
    _ingredientsController.text = food.ingredients;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final foodItem = FoodItem(
      id: widget.foodItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      petId: widget.petId,
      name: _nameController.text,
      type: _selectedType,
      servingSize: double.parse(_servingSizeController.text),
      unit: _selectedUnit,
      calories: double.parse(_caloriesController.text),
      protein: double.tryParse(_proteinController.text),
      fat: double.tryParse(_fatController.text),
      fiber: double.tryParse(_fiberController.text),
      ingredients: _ingredientsController.text,
    );

    Navigator.pop(context, foodItem);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: CustomCard(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.foodItem == null ? 'Add Food Item' : 'Edit Food Item',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter food name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Food Type',
                          border: OutlineInputBorder(),
                        ),
                        items: _foodTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _servingSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Serving Size',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        items: _units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calories (per serving)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter calories';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _proteinController,
                        decoration: const InputDecoration(
                          labelText: 'Protein (g)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _fatController,
                        decoration: const InputDecoration(
                          labelText: 'Fat (g)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _fiberController,
                        decoration: const InputDecoration(
                          labelText: 'Fiber (g)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredients (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Enter main ingredients',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      onPressed: () => Navigator.pop(context),
                      text: 'Cancel',
                      type: ButtonType.secondary,
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      onPressed: _isLoading ? null : _submitForm,
                      text: widget.foodItem == null ? 'Add' : 'Save',
                      icon: _isLoading ? null : Icons.check,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}