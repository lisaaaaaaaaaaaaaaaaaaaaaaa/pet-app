import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../utils/validators.dart';

class PetLifestyleScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final Future<bool> Function() onBack;

  const PetLifestyleScreen({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<PetLifestyleScreen> createState() => _PetLifestyleScreenState();
}

class _PetLifestyleScreenState extends State<PetLifestyleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activityLevelController = TextEditingController();
  final _dietaryNotesController = TextEditingController();
  final _behaviorNotesController = TextEditingController();
  String _selectedActivityLevel = 'Moderate';
  String _selectedDiet = 'Commercial';
  bool _isIndoor = true;

  final List<String> _activityLevels = ['Low', 'Moderate', 'High', 'Very High'];
  final List<String> _dietTypes = ['Commercial', 'Home-cooked', 'Raw', 'Mixed'];

  @override
  void dispose() {
    _activityLevelController.dispose();
    _dietaryNotesController.dispose();
    _behaviorNotesController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.onNext({
        'activityLevel': _selectedActivityLevel,
        'dietType': _selectedDiet,
        'isIndoor': _isIndoor,
        'dietaryNotes': _dietaryNotesController.text,
        'behaviorNotes': _behaviorNotesController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedActivityLevel,
              decoration: const InputDecoration(
                labelText: 'Activity Level',
              ),
              items: _activityLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivityLevel = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Indoor Pet'),
              subtitle: const Text('Does your pet live primarily indoors?'),
              value: _isIndoor,
              onChanged: (value) {
                setState(() {
                  _isIndoor = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDiet,
              decoration: const InputDecoration(
                labelText: 'Diet Type',
              ),
              items: _dietTypes.map((diet) {
                return DropdownMenuItem(
                  value: diet,
                  child: Text(diet),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDiet = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _dietaryNotesController,
              label: 'Dietary Notes',
              maxLines: 3,
              helperText: 'Include any special dietary requirements or preferences',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _behaviorNotesController,
              label: 'Behavior Notes',
              maxLines: 3,
              helperText: 'Describe your pet\'s temperament and any behavioral considerations',
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              onPressed: _handleNext,
              label: 'Next',
            ),
          ],
        ),
      ),
    );
  }
}
