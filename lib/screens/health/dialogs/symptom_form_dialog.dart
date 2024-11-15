import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/symptom_log.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_formatter.dart';
import '../../../widgets/common/custom_text_field.dart';

class SymptomFormDialog extends StatefulWidget {
  final String title;
  final String petId;
  final SymptomLog? symptom;

  const SymptomFormDialog({
    Key? key,
    required this.title,
    required this.petId,
    this.symptom,
  }) : super(key: key);

  @override
  State<SymptomFormDialog> createState() => _SymptomFormDialogState();
}

class _SymptomFormDialogState extends State<SymptomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _notesController;
  late DateTime _observedAt;
  int _severity = 1;
  bool _isLoading = false;

  final List<String> _commonSymptoms = [
    'Vomiting',
    'Diarrhea',
    'Loss of Appetite',
    'Lethargy',
    'Coughing',
    'Sneezing',
    'Limping',
    'Scratching',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _typeController = TextEditingController(text: widget.symptom?.type);
    _notesController = TextEditingController(text: widget.symptom?.notes);
    _observedAt = widget.symptom?.observedAt ?? DateTime.now();
    _severity = widget.symptom?.severity ?? 1;
  }

  @override
  void dispose() {
    _typeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _observedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryGreen),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_observedAt),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: AppTheme.primaryGreen),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _observedAt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showSymptomPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Common Symptoms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSymptoms.map((symptom) {
                return ChoiceChip(
                  label: Text(symptom),
                  selected: _typeController.text == symptom,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _typeController.text = symptom;
                      });
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getSeverityLabel(int severity) {
    switch (severity) {
      case 1:
        return 'Mild';
      case 2:
        return 'Moderate';
      case 3:
        return 'Severe';
      default:
        return 'Unknown';
    }
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final symptom = SymptomLog(
        id: widget.symptom?.id,
        petId: widget.petId,
        type: _typeController.text.trim(),
        severity: _severity,
        observedAt: _observedAt,
        notes: _notesController.text.trim(),
      );

      Navigator.of(context).pop(symptom);
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
          child: Icon(
            Icons.healing_outlined,
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
        _buildSymptomField(),
        const SizedBox(height: 16),
        _buildSeveritySlider(),
        const SizedBox(height: 16),
        _buildDateTimePicker(),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _notesController,
          label: 'Notes',
          icon: Icons.note_outlined,
          maxLines: 3,
          hint: 'Add any additional observations...',
        ),
      ],
    );
  }

  Widget _buildSymptomField() {
    return GestureDetector(
      onTap: _showSymptomPicker,
      child: AbsorbPointer(
        child: CustomTextField(
          controller: _typeController,
          label: 'Symptom Type',
          icon: Icons.healing_outlined,
          suffix: const Icon(Icons.arrow_drop_down),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select or enter a symptom';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildSeveritySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: _getSeverityColor(_severity)),
            const SizedBox(width: 8),
            Text(
              'Severity: ${_getSeverityLabel(_severity)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Slider(
          value: _severity.toDouble(),
          min: 1,
          max: 3,
          divisions: 2,
          activeColor: _getSeverityColor(_severity),
          label: _getSeverityLabel(_severity),
          onChanged: (value) {
            setState(() => _severity = value.round());
          },
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
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
                  'Observed At',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  DateFormatter.formatDateTime(_observedAt),
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
