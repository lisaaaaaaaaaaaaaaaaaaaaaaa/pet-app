// lib/screens/pet/pet_profile_settings.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pet_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../utils/validators.dart';
import '../../utils/form_formatters.dart';

class PetProfileSettings extends StatefulWidget {
  final String petId;

  const PetProfileSettings({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  State<PetProfileSettings> createState() => _PetProfileSettingsState();
}

class _PetProfileSettingsState extends State<PetProfileSettings> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;
  bool _hasChanges = false;
  PetProfile? _originalProfile;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadPetProfile();
  }

  Future<void> _loadPetProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await context.read<PetProvider>().loadPetProfile(widget.petId);
      _originalProfile = profile;
      _updateControllers(profile);
    } catch (e) {
      _showErrorSnackBar('Failed to load pet profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeControllers() {
    final fields = [
      'name',
      'breed',
      'weight',
      'color',
      'microchipNumber',
      'veterinarianInfo',
      'emergencyContact',
      'insuranceInfo',
      'allergies',
      'medications',
      'specialNeeds',
    ];

    for (final field in fields) {
      _controllers[field] = TextEditingController()
        ..addListener(() {
          if (!_hasChanges) {
            setState(() => _hasChanges = true);
          }
        });
    }
  }

  void _updateControllers(PetProfile profile) {
    _controllers['name']?.text = profile.name;
    _controllers['breed']?.text = profile.breed;
    _controllers['weight']?.text = profile.weight.toString();
    _controllers['color']?.text = profile.color;
    _controllers['microchipNumber']?.text = profile.microchipNumber;
    _controllers['veterinarianInfo']?.text = profile.veterinarianInfo;
    _controllers['emergencyContact']?.text = profile.emergencyContact;
    _controllers['insuranceInfo']?.text = profile.insuranceInfo;
    _controllers['allergies']?.text = profile.allergies.join(', ');
    _controllers['medications']?.text = profile.medications.join(', ');
    _controllers['specialNeeds']?.text = profile.specialNeeds ?? '';
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Discard Changes?',
        content: 'You have unsaved changes. Are you sure you want to discard them?',
        confirmText: 'Discard',
        cancelText: 'Keep Editing',
        isDestructive: true,
      ),
    );

    return result ?? false;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final updatedProfile = _buildUpdatedProfile();
      await context.read<PetProvider>().updatePetProfile(
        petId: widget.petId,
        profile: updatedProfile,
      );
      
      _hasChanges = false;
      _showSuccessSnackBar('Changes saved successfully');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to save changes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ... (continued in next part)
  // Continuing lib/screens/pet/pet_profile_settings.dart

  PetProfile _buildUpdatedProfile() {
    return PetProfile(
      id: widget.petId,
      name: _controllers['name']!.text.trim(),
      breed: _controllers['breed']!.text.trim(),
      weight: double.tryParse(_controllers['weight']!.text) ?? 0.0,
      color: _controllers['color']!.text.trim(),
      microchipNumber: _controllers['microchipNumber']!.text.trim(),
      veterinarianInfo: _controllers['veterinarianInfo']!.text.trim(),
      emergencyContact: _controllers['emergencyContact']!.text.trim(),
      insuranceInfo: _controllers['insuranceInfo']!.text.trim(),
      allergies: _parseListField(_controllers['allergies']!.text),
      medications: _parseListField(_controllers['medications']!.text),
      specialNeeds: _controllers['specialNeeds']!.text.trim(),
      photoUrl: _originalProfile?.photoUrl ?? '',
      lastUpdated: DateTime.now(),
    );
  }

  List<String> _parseListField(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildForm(),
            if (_isLoading) const LoadingOverlay(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Edit Profile'),
      actions: [
        if (_hasChanges)
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _saveChanges,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBasicInfoSection(),
            _buildMedicalInfoSection(),
            _buildEmergencySection(),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      'Basic Information',
      [
        _buildTextField(
          controller: _controllers['name']!,
          label: 'Pet Name',
          validator: Validators.required('Please enter your pet\'s name'),
          textCapitalization: TextCapitalization.words,
        ),
        _buildTextField(
          controller: _controllers['breed']!,
          label: 'Breed',
          textCapitalization: TextCapitalization.words,
        ),
        _buildTextField(
          controller: _controllers['weight']!,
          label: 'Weight (kg)',
          keyboardType: TextInputType.number,
          validator: Validators.number('Please enter a valid weight'),
          inputFormatters: [FormFormatters.decimal()],
        ),
        _buildTextField(
          controller: _controllers['color']!,
          label: 'Color',
          textCapitalization: TextCapitalization.words,
        ),
        _buildTextField(
          controller: _controllers['microchipNumber']!,
          label: 'Microchip Number',
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }

  Widget _buildMedicalInfoSection() {
    return _buildSection(
      'Medical Information',
      [
        _buildTextField(
          controller: _controllers['veterinarianInfo']!,
          label: 'Veterinarian Information',
          maxLines: 3,
          helperText: 'Include name, address, and contact information',
        ),
        _buildTextField(
          controller: _controllers['allergies']!,
          label: 'Allergies',
          helperText: 'Separate multiple allergies with commas',
          maxLines: 2,
        ),
        _buildTextField(
          controller: _controllers['medications']!,
          label: 'Current Medications',
          helperText: 'Separate multiple medications with commas',
          maxLines: 2,
        ),
        _buildTextField(
          controller: _controllers['specialNeeds']!,
          label: 'Special Needs or Conditions',
          maxLines: 3,
        ),
      ],
    );
  }

  // ... (continued in next part)
  // Continuing lib/screens/pet/pet_profile_settings.dart

  Widget _buildEmergencySection() {
    return _buildSection(
      'Emergency Information',
      [
        _buildTextField(
          controller: _controllers['emergencyContact']!,
          label: 'Emergency Contact',
          helperText: 'Include name, relationship, and phone number',
          maxLines: 2,
          keyboardType: TextInputType.multiline,
        ),
        _buildTextField(
          controller: _controllers['insuranceInfo']!,
          label: 'Pet Insurance Information',
          helperText: 'Include provider, policy number, and contact details',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return _buildSection(
      'Danger Zone',
      [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'The following actions are irreversible. Please proceed with caution.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _showDeactivateConfirmation,
          icon: const Icon(Icons.pause_circle_outlined),
          label: const Text('Deactivate Profile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _showDeleteConfirmation,
          icon: const Icon(Icons.delete_forever),
          label: const Text('Delete Profile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperMaxLines: 2,
          border: const OutlineInputBorder(),
          errorMaxLines: 2,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }

  Future<void> _showDeactivateConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Deactivate Pet Profile',
        content: 'This will temporarily hide your pet\'s profile. '
                'You can reactivate it at any time. Continue?',
        confirmText: 'Deactivate',
        isDestructive: true,
      ),
    );

    if (confirmed == true) {
      await _deactivateProfile();
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Delete Pet Profile',
        content: 'This will permanently delete your pet\'s profile and all associated data. '
                'This action cannot be undone. Are you sure?',
        confirmText: 'Delete Forever',
        isDestructive: true,
      ),
    );

    if (confirmed == true) {
      await _deleteProfile();
    }
  }

  Future<void> _deactivateProfile() async {
    setState(() => _isLoading = true);
    try {
      await context.read<PetProvider>().deactivatePetProfile(widget.petId);
      _showSuccessSnackBar('Profile deactivated successfully');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to deactivate profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProfile() async {
    setState(() => _isLoading = true);
    try {
      await context.read<PetProvider>().deletePetProfile(widget.petId);
      _showSuccessSnackBar('Profile deleted successfully');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to delete profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _saveChanges,
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