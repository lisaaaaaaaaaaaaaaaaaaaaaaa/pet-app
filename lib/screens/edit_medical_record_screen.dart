import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/pet_provider.dart';
import '../../models/medical_record.dart';
import '../../theme/app_theme.dart';

class EditMedicalRecordScreen extends StatefulWidget {
  final MedicalRecord record;

  const EditMedicalRecordScreen({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  State<EditMedicalRecordScreen> createState() => _EditMedicalRecordScreenState();
}

class _EditMedicalRecordScreenState extends State<EditMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _conditionController;
  late TextEditingController _treatmentController;
  late TextEditingController _notesController;
  late TextEditingController _vetNameController;
  late TextEditingController _costController;
  
  DateTime _date = DateTime.now();
  DateTime? _followUpDate;
  List<PlatformFile> _attachments = [];
  bool _isLoading = false;
  bool _requiresFollowUp = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _conditionController = TextEditingController(text: widget.record.condition);
    _treatmentController = TextEditingController(text: widget.record.treatment);
    _notesController = TextEditingController(text: widget.record.notes);
    _vetNameController = TextEditingController(text: widget.record.vetName);
    _costController = TextEditingController(
      text: widget.record.cost > 0 ? widget.record.cost.toString() : '',
    );
    _date = widget.record.date;
    _followUpDate = widget.record.followUpDate;
    _requiresFollowUp = widget.record.followUpDate != null;
    // TODO: Initialize attachments from record
  }

  @override
  void dispose() {
    _conditionController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    _vetNameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {bool isFollowUp = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFollowUp ? DateTime.now() : _date,
      firstDate: DateTime(2000),
      lastDate: isFollowUp ? DateTime(2100) : DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFollowUp) {
          _followUpDate = picked;
        } else {
          _date = picked;
        }
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _attachments = result.files;
          _hasChanges = true;
        });
      }
    } catch (e) {
      _showError('Error picking files: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _saveMedicalRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedRecord = widget.record.copyWith(
        date: _date,
        condition: _conditionController.text,
        treatment: _treatmentController.text,
        vetName: _vetNameController.text,
        cost: double.tryParse(_costController.text) ?? 0.0,
        notes: _notesController.text,
        followUpDate: _requiresFollowUp ? _followUpDate : null,
        lastUpdated: DateTime.now(),
      );

      await context.read<PetProvider>().updateMedicalRecord(updatedRecord);

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical record updated successfully')),
      );
    } catch (e) {
      _showError('Error updating medical record: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Medical Record'),
          actions: [
            if (_hasChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _isLoading ? null : _saveMedicalRecord,
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  onChanged: () {
                    if (!_hasChanges) {
                      setState(() => _hasChanges = true);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfo(),
                      const SizedBox(height: 24),
                      _buildTreatmentInfo(),
                      const SizedBox(height: 24),
                      _buildFollowUpSection(),
                      const SizedBox(height: 24),
                      _buildAttachmentsSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('MMM dd, yyyy').format(_date)),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _conditionController,
          decoration: const InputDecoration(
            labelText: 'Condition/Reason',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the condition';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _vetNameController,
          decoration: const InputDecoration(
            labelText: 'Veterinarian Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _costController,
          decoration: const InputDecoration(
            labelText: 'Cost',
            border: OutlineInputBorder(),
            prefixText: '\$',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTreatmentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Treatment Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _treatmentController,
          decoration: const InputDecoration(
            labelText: 'Treatment',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the treatment';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Additional Notes',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildFollowUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow-up',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Requires Follow-up'),
          value: _requiresFollowUp,
          onChanged: (value) {
            setState(() {
              _requiresFollowUp = value;
              _hasChanges = true;
              if (!value) {
                _followUpDate = null;
              }
            });
          },
        ),
        if (_requiresFollowUp) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context, isFollowUp: true),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Follow-up Date',
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _followUpDate != null
                        ? DateFormat('MMM dd, yyyy').format(_followUpDate!)
                        : 'Select date',
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_attachments.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final file = _attachments[index];
              return ListTile(
                leading: Icon(
                  file.extension == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                ),
                title: Text(file.name),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _attachments.removeAt(index);
                      _hasChanges = true;
                    });
                  },
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.attach_file),
          label: const Text('Add Attachments'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black87,
          ),
        ),
      ],
    );
  }
}