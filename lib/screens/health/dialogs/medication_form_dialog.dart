import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../models/medication.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/custom_text_field.dart';

class MedicationFormDialog extends StatefulWidget {
  final String title;
  final String petId;
  final Medication? medication;

  const MedicationFormDialog({
    Key? key,
    required this.title,
    required this.petId,
    this.medication,
  }) : super(key: key);

  @override
  State<MedicationFormDialog> createState() => _MedicationFormDialogState();
}

class _MedicationFormDialogState extends State<MedicationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _instructionsController;
  late TextEditingController _frequencyController;
  late DateTime _nextDose;
  late TimeOfDay _reminderTime;
  bool _isLoading = false;
  bool _setReminder = false;
  String _frequency = 'daily';

  final List<String> _frequencies = [
    'daily',
    'twice_daily',
    'weekly',
    'monthly',
    'as_needed',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.medication?.name);
    _dosageController = TextEditingController(text: widget.medication?.dosage);
    _instructionsController = TextEditingController(text: widget.medication?.instructions);
    _frequencyController = TextEditingController(text: widget.medication?.frequency);
    _nextDose = widget.medication?.nextDose ?? DateTime.now();
    _reminderTime = TimeOfDay.fromDateTime(widget.medication?.nextDose ?? DateTime.now());
    _frequency = widget.medication?.frequency ?? 'daily';
    _setReminder = widget.medication?.hasReminder ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _nextDose,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryGreen),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_nextDose),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppTheme.primaryGreen),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _nextDose = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _reminderTime = pickedTime;
        });
      }
    }
  }

  String _getFrequencyLabel(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Once Daily';
      case 'twice_daily':
        return 'Twice Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'as_needed':
        return 'As Needed';
      default:
        return 'Custom';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final medication = Medication(
        id: widget.medication?.id,
        petId: widget.petId,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        instructions: _instructionsController.text.trim(),
        frequency: _frequency,
        nextDose: _nextDose,
        hasReminder: _setReminder,
        reminderTime: _reminderTime,
        isCompleted: widget.medication?.isCompleted ?? false,
        completedAt: widget.medication?.completedAt,
      );

      Navigator.of(context).pop(medication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildForm(),
                const SizedBox(height: 24),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.medication_outlined,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _nameController,
          label: 'Medication Name',
          icon: Icons.medication_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter medication name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _dosageController,
          label: 'Dosage',
          icon: Icons.scale_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter dosage';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFrequencyDropdown(),
        const SizedBox(height: 16),
        _buildNextDoseField(),
        const SizedBox(height: 16),
        _buildReminderToggle(),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _instructionsController,
          label: 'Instructions',
          icon: Icons.description_outlined,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter instructions';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _frequency,
      decoration: InputDecoration(
        labelText: 'Frequency',
        prefixIcon: const Icon(Icons.repeat),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _frequencies.map((frequency) {
        return DropdownMenuItem(
          value: frequency,
          child: Text(_getFrequencyLabel(frequency)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _frequency = value);
        }
      },
    );
  }

  Widget _buildNextDoseField() {
    return InkWell(
      onTap: _selectDateTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Dose',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  DateFormat('MMM d, y h:mm a').format(_nextDose),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderToggle() {
    return SwitchListTile(
      title: const Text('Set Reminder'),
      subtitle: Text(
        'Receive notifications for this medication',
        style: TextStyle(color: Colors.grey[600]),
      ),
      value: _setReminder,
      onChanged: (value) {
        setState(() => _setReminder = value);
      },
      activeColor: AppTheme.primaryGreen,
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
