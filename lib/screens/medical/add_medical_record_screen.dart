// lib/screens/medical/add_medical_record_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/pet_provider.dart';
import '../../providers/storage_provider.dart';
import '../../models/medical_record.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../utils/file_helper.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/attachment_list.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final String petId;

  const AddMedicalRecordScreen({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  
  DateTime _date = DateTime.now();
  DateTime? _followUpDate;
  List<PlatformFile> _attachments = [];
  bool _isLoading = false;
  bool _requiresFollowUp = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = [
      'condition',
      'treatment',
      'notes',
      'vetName',
      'cost',
    ];

    for (final field in fields) {
      _controllers[field] = TextEditingController()
        ..addListener(() {
          if (!_hasUnsavedChanges) {
            setState(() => _hasUnsavedChanges = true);
          }
        });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('KEEP EDITING'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DISCARD'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _selectDate(BuildContext context, {bool isFollowUp = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFollowUp ? DateTime.now() : _date,
      firstDate: isFollowUp ? DateTime.now() : DateTime(2000),
      lastDate: isFollowUp ? DateTime(2100) : DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFollowUp) {
          _followUpDate = picked;
        } else {
          _date = picked;
        }
        _hasUnsavedChanges = true;
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
        // Validate file sizes
        final validFiles = await FileHelper.validateFiles(
          result.files,
          maxSizeInMB: 10,
        );

        setState(() {
          _attachments.addAll(validFiles);
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking files: $e');
    }
  }

  Future<void> _saveMedicalRecord() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill in all required fields');
      return;
    }

    if (_requiresFollowUp && _followUpDate == null) {
      _showErrorSnackBar('Please select a follow-up date');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storageProvider = context.read<StorageProvider>();
      final attachmentUrls = await Future.wait(
        _attachments.map((file) => storageProvider.uploadMedicalFile(
          petId: widget.petId,
          file: file,
        )),
      );

      final medicalRecord = MedicalRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.petId,
        date: _date,
        condition: _controllers['condition']!.text.trim(),
        treatment: _controllers['treatment']!.text.trim(),
        vetName: _controllers['vetName']!.text.trim(),
        cost: double.tryParse(_controllers['cost']!.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0,
        notes: _controllers['notes']!.text.trim(),
        requiresFollowUp: _requiresFollowUp,
        followUpDate: _followUpDate,
        attachments: attachmentUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await context.read<PetProvider>().addMedicalRecord(medicalRecord);

      if (!mounted) return;

      _showSuccessSnackBar('Medical record added successfully');
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackBar('Error saving medical record: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Medical Record'),
          actions: [
            if (_hasUnsavedChanges)
              TextButton.icon(
                onPressed: _isLoading ? null : _saveMedicalRecord,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    _buildBasicInfo(),
                    const SizedBox(height: 16),
                    _buildTreatmentInfo(),
                    const SizedBox(height: 16),
                    _buildFollowUpSection(),
                    const SizedBox(height: 16),
                    _buildAttachmentsSection(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
            if (_isLoading) const LoadingOverlay(),
          ],
        ),
      ),
    );
  }

  // ... (continuing with the UI components in the next part)
  // Continuing lib/screens/medical/add_medical_record_screen.dart

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM dd, yyyy').format(_date),
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            CustomTextField(
              controller: _controllers['condition']!,
              label: 'Condition/Diagnosis',
              validator: Validators.required('Please enter the condition'),
              prefixIcon: Icons.medical_services_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _controllers['vetName']!,
              label: 'Veterinarian Name',
              validator: Validators.required('Please enter the veterinarian name'),
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _controllers['cost']!,
              label: 'Cost',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyFormatter()],
              helperText: 'Optional',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Treatment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _controllers['treatment']!,
              label: 'Treatment',
              validator: Validators.required('Please enter the treatment'),
              prefixIcon: Icons.healing_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _controllers['notes']!,
              label: 'Additional Notes',
              prefixIcon: Icons.note_outlined,
              maxLines: 3,
              helperText: 'Optional',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Follow-up',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              title: const Text('Requires Follow-up'),
              subtitle: const Text('Schedule a follow-up appointment'),
              value: _requiresFollowUp,
              onChanged: (value) {
                setState(() {
                  _requiresFollowUp = value;
                  if (!value) {
                    _followUpDate = null;
                  }
                  _hasUnsavedChanges = true;
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
                    prefixIcon: Icon(Icons.event),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _followUpDate != null
                            ? DateFormat('MMMM dd, yyyy').format(_followUpDate!)
                            : 'Select date',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Files'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_attachments.isNotEmpty)
              AttachmentList(
                attachments: _attachments,
                onRemove: (index) {
                  setState(() {
                    _attachments.removeAt(index);
                    _hasUnsavedChanges = true;
                  });
                },
              ),
            if (_attachments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No attachments added yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveMedicalRecord,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
      ),
      child: Text(
        _isLoading ? 'Saving...' : 'Save Medical Record',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}