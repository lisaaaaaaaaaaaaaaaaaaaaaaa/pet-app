import 'package:flutter/material.dart';
import '../common/custom_card.dart';
import '../common/loading_indicator.dart';
import '../custom_button.dart';
import '../../models/meal.dart';
import '../../models/food_item.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class AddMealDialog extends StatefulWidget {
  final String petId;
  final DateTime date;
  final Meal? meal;

  const AddMealDialog({
    Key? key,
    required this.petId,
    required this.date,
    this.meal,
  }) : super(key: key);

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  late TimeOfDay _selectedTime;
  String _selectedType = 'Breakfast';
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.now();
    if (widget.meal != null) {
      _initializeWithMeal(widget.meal!);
    }
  }

  void _initializeWithMeal(Meal meal) {
    _selectedTime = TimeOfDay.fromDateTime(meal.time);
    _selectedType = meal.type;
    _amountController.text = meal.amount.toString();
    _notesController.text = meal.notes;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final meal = Meal(
      id: widget.meal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      petId: widget.petId,
      type: _selectedType,
      time: DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      amount: double.parse(_amountController.text),
      unit: 'cups',
      notes: _notesController.text,
    );

    Navigator.pop(context, meal);
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
                  widget.meal == null ? 'Add Meal' : 'Edit Meal',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Meal Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _mealTypes.map((type) {
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
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedTime.format(context)),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (cups)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
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
                      text: widget.meal == null ? 'Add' : 'Save',
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