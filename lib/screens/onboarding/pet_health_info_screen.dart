import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../utils/validators.dart';

class PetHealthInfoScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final Future<bool> Function() onBack;

  const PetHealthInfoScreen({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<PetHealthInfoScreen> createState() => _PetHealthInfoScreenState();
}

class _PetHealthInfoScreenState extends State<PetHealthInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  bool _isSpayedNeutered = false;
  bool _hasAllergies = false;
  bool _hasMedicalConditions = false;

  @override
  void dispose() {
    _weightController.dispose();
    _microchipController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.onNext({
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'microchipNumber': _microchipController.text,
        'isSpayedNeutered': _isSpayedNeutered,
        'hasAllergies': _hasAllergies,
        'allergies': _hasAllergies ? _allergiesController.text : null,
        'hasMedicalConditions': _hasMedicalConditions,
        'medicalConditions': _hasMedicalConditions ? _conditionsController.text : null,
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
            CustomTextField(
              controller: _weightController,
              label: 'Weight (kg)',
              keyboardType: TextInputType.number,
              validator: Validators.required('Please enter your pet\'s weight'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _microchipController,
              label: 'Microchip Number (optional)',
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Spayed/Neutered'),
              value: _isSpayedNeutered,
              onChanged: (value) {
                setState(() {
                  _isSpayedNeutered = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Has Allergies'),
              value: _hasAllergies,
              onChanged: (value) {
                setState(() {
                  _hasAllergies = value;
                });
              },
            ),
            if (_hasAllergies) ...[
              const SizedBox(height: 16),
              CustomTextField(
                controller: _allergiesController,
                label: 'Allergies',
                maxLines: 3,
                validator: _hasAllergies
                    ? Validators.required('Please describe your pet\'s allergies')
                    : null,
              ),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Has Medical Conditions'),
              value: _hasMedicalConditions,
              onChanged: (value) {
                setState(() {
                  _hasMedicalConditions = value;
                });
              },
            ),
            if (_hasMedicalConditions) ...[
              const SizedBox(height: 16),
              CustomTextField(
                controller: _conditionsController,
                label: 'Medical Conditions',
                maxLines: 3,
                validator: _hasMedicalConditions
                    ? Validators.required('Please describe your pet\'s medical conditions')
                    : null,
              ),
            ],
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
