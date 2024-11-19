import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pet_provider.dart';
import '../../models/symptom_record.dart';
import '../../theme/app_theme.dart';

class SymptomLoggerScreen extends StatefulWidget {
  const SymptomLoggerScreen({Key? key}) : super(key: key);

  @override
  State<SymptomLoggerScreen> createState() => _SymptomLoggerScreenState();
}

class _SymptomLoggerScreenState extends State<SymptomLoggerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedSeverity = 'Mild';
  final List<String> _selectedSymptoms = [];
  bool _isLoading = false;

  final List<String> _severityLevels = ['Mild', 'Moderate', 'Severe'];
  final List<String> _commonSymptoms = [
    'Vomiting',
    'Diarrhea',
    'Lethargy',
    'Loss of Appetite',
    'Coughing',
    'Sneezing',
    'Limping',
    'Scratching',
    'Changes in Behavior',
    'Excessive Thirst',
  ];

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveSymptomRecord() async {
    if (!_formKey.currentState!.validate() || _selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one symptom'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final DateTime recordDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final symptomRecord = SymptomRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symptoms: _selectedSymptoms,
        severity: _selectedSeverity,
        date: recordDateTime,
        notes: _notesController.text.trim(),
      );

      await context.read<PetProvider>().addSymptomRecord(symptomRecord);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Symptom record saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving symptom record: $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Symptoms'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateTimePickers(),
              const SizedBox(height: 24),
              _buildSymptomSelector(),
              const SizedBox(height: 24),
              _buildSeveritySelector(),
              const SizedBox(height: 24),
              _buildNotesField(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _isLoading ? null : _selectDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                DateFormat('MMM d, y').format(_selectedDate),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: _isLoading ? null : _selectTime,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Time',
                prefixIcon: Icon(Icons.access_time),
              ),
              child: Text(
                _selectedTime.format(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Symptoms',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonSymptoms.map((symptom) {
            final isSelected = _selectedSymptoms.contains(symptom);
            return FilterChip(
              label: Text(symptom),
              selected: isSelected,
              onSelected: _isLoading
                  ? null
                  : (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeveritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Severity Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: _severityLevels.map((level) {
            return ButtonSegment<String>(
              value: level,
              label: Text(level),
            );
          }).toList(),
          selected: {_selectedSeverity},
          onSelectionChanged: _isLoading
              ? null
              : (Set<String> newSelection) {
                  setState(() {
                    _selectedSeverity = newSelection.first;
                  });
                },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return Colors.transparent;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Additional Notes',
        hintText: 'Add any additional observations...',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      enabled: !_isLoading,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSymptomRecord,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
            : const Text(
                'Save Symptom Record',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}