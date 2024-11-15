import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
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

[Rest of the PetProfileSettings code you shared, including all build methods and helper functions]

  void _showSubscriptionRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Required'),
        content: const Text('This feature requires an active subscription.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text('SUBSCRIBE NOW'),
          ),
        ],
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
