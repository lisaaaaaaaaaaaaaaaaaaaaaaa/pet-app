import 'package:flutter/material.dart';
import '../../models/meal.dart';
import '../../models/food.dart';
import '../../theme/app_theme.dart';
import '../common/custom_card.dart';

class AddMealDialog extends StatefulWidget {
  final Meal? initialMeal;
  final List<Food> availableFoods;
  final Function(Meal meal) onSave;

  const AddMealDialog({
    Key? key,
    this.initialMeal,
    required this.availableFoods,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TimeOfDay _selectedTime;
  late List<Food> _selectedFoods;
  late Map<String, double> _portions;
  MealType _selectedType = MealType.breakfast;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialMeal?.name);
    _selectedTime = widget.initialMeal?.time ?? TimeOfDay.now();
    _selectedFoods = List.from(widget.initialMeal?.foods ?? []);
    _portions = Map.from(widget.initialMeal?.portions ?? {});
    _selectedType = widget.initialMeal?.type ?? MealType.breakfast;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final meal = Meal(
        id: widget.initialMeal?.id ?? DateTime.now().toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        time: _selectedTime,
        foods: _selectedFoods,
        portions: _portions,
        dateAdded: widget.initialMeal?.dateAdded ?? DateTime.now(),
      );

      widget.onSave(meal);
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addFood(Food food) {
    setState(() {
      if (!_selectedFoods.contains(food)) {
        _selectedFoods.add(food);
        _portions[food.id] = 1.0;
      }
    });
  }

  void _removeFood(Food food) {
    setState(() {
      _selectedFoods.remove(food);
      _portions.remove(food.id);
    });
  }

  void _updatePortion(Food food, double portion) {
    setState(() {
      _portions[food.id] = portion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Text(
                    widget.initialMeal != null ? 'Edit Meal' : 'Add New Meal',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Meal Name*',
                      hintText: 'Enter meal name',
                      prefixIcon: Icon(Icons.restaurant),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a meal name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Meal Type Selector
                  DropdownButtonFormField<MealType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Meal Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: MealType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Time Picker
                  InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Meal Time',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _selectedTime.format(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Foods Section
                  const Text(
                    'Foods',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Selected Foods List
                  if (_selectedFoods.isNotEmpty) ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedFoods.length,
                      itemBuilder: (context, index) {
                        final food = _selectedFoods[index];
                        return ListTile(
                          title: Text(food.name),
                          subtitle: Text('${food.calories} calories per serving'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  initialValue: _portions[food.id].toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    suffix: Text('×'),
                                  ),
                                  onChanged: (value) {
                                    _updatePortion(
                                      food,
                                      double.tryParse(value) ?? 1.0,
                                    );
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: AppTheme.errorColor,
                                onPressed: () => _removeFood(food),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Add Food Button
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _FoodSelectionDialog(
                          availableFoods: widget.availableFoods
                              .where((f) => !_selectedFoods.contains(f))
                              .toList(),
                          onFoodSelected: _addFood,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Food'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _selectedFoods.isEmpty ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Food Selection Dialog
class _FoodSelectionDialog extends StatelessWidget {
  final List<Food> availableFoods;
  final Function(Food) onFoodSelected;

  const _FoodSelectionDialog({
    required this.availableFoods,
    required this.onFoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Food',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableFoods.length,
                itemBuilder: (context, index) {
                  final food = availableFoods[index];
                  return ListTile(
                    title: Text(food.name),
                    subtitle: Text(
                      '${food.calories} calories per ${food.servingSize}',
                    ),
                    onTap: () {
                      onFoodSelected(food);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}