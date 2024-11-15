import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/date_picker_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../utils/validators.dart';

class PetBasicInfoScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final Future<bool> Function() onBack;

  const PetBasicInfoScreen({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<PetBasicInfoScreen> createState() => _PetBasicInfoScreenState();
}

class _PetBasicInfoScreenState extends State<PetBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  DateTime? _dateOfBirth;
  String _selectedSpecies = 'Dog';

  final List<String> _speciesOptions = ['Dog', 'Cat', 'Bird', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate() && _dateOfBirth != null) {
      widget.onNext({
        'name': _nameController.text,
        'species': _selectedSpecies,
        'breed': _breedController.text,
        'dateOfBirth': _dateOfBirth,
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
              controller: _nameController,
              label: 'Pet Name',
              validator: Validators.required('Please enter your pet\'s name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Species',
              ),
              items: _speciesOptions.map((species) {
                return DropdownMenuItem(
                  value: species,
                  child: Text(species),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpecies = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _breedController,
              label: 'Breed',
              validator: Validators.required('Please enter your pet\'s breed'),
            ),
            const SizedBox(height: 16),
            DatePickerField(
              label: 'Date of Birth',
              selectedDate: _dateOfBirth,
              onDateSelected: (date) {
                setState(() {
                  _dateOfBirth = date;
                });
              },
              validator: (value) {
                if (_dateOfBirth == null) {
                  return 'Please select your pet\'s date of birth';
                }
                return null;
              },
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
