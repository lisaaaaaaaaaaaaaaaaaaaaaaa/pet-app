import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../providers/pet_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pet.dart';
import '../../models/pet_profile.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../utils/validators.dart';
import '../../utils/image_helper.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/date_picker_field.dart';
import '../../widgets/common/image_picker_bottom_sheet.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final _scrollController = ScrollController();
  
  String _selectedSpecies = 'Dog';
  String _selectedGender = 'Male';
  DateTime _dateOfBirth = DateTime.now();
  File? _selectedImage;
  bool _isLoading = false;
  bool _hasSpecialNeeds = false;
  bool _hasUnsavedChanges = false;

  final List<String> _speciesList = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  final List<String> _genderList = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _checkSubscriptionAndPetLimit();
    _initializeControllers();
  }

  Future<void> _checkSubscriptionAndPetLimit() async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    final petProvider = context.read<PetProvider>();
    
    if (!subscriptionProvider.isSubscribed && 
        petProvider.pets.length >= subscriptionProvider.freeTierPetLimit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSubscriptionNeededDialog();
      });
    }
  }

  void _initializeControllers() {
    final fields = [
      'name',
      'breed',
      'weight',
      'color',
      'microchip',
      'veterinarianInfo',
      'emergencyContact',
      'notes',
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

  void _showSubscriptionNeededDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Required'),
        content: const Text(
          'You\'ve reached the maximum number of pets for your current plan. '
          'Upgrade to add more pets and unlock premium features.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text('UPGRADE'),
          ),
        ],
      ),
    );
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await ImageHelper.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      final croppedImage = await ImageHelper.cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (croppedImage == null) return;

      setState(() {
        _selectedImage = File(croppedImage.path);
        _hasUnsavedChanges = true;
      });
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ImagePickerBottomSheet(
        onCameraTap: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGalleryTap: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
    
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final petId = DateTime.now().millisecondsSinceEpoch.toString();
      String? photoUrl;

      if (_selectedImage != null) {
        photoUrl = await StorageService().uploadPetImage(
          _selectedImage!,
          petId,
          onProgress: (progress) {
            // TODO: Implement upload progress indicator
          },
        );
      }

      final newPet = Pet(
        id: petId,
        userId: userId,
        name: _controllers['name']!.text.trim(),
        species: _selectedSpecies,
        breed: _controllers['breed']!.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _selectedGender,
        weight: double.tryParse(_controllers['weight']!.text) ?? 0.0,
        photoUrl: photoUrl ?? '',
        isActive: true,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      final newProfile = PetProfile(
        id: petId,
        name: _controllers['name']!.text.trim(),
        species: _selectedSpecies,
        breed: _controllers['breed']!.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _selectedGender,
        weight: double.tryParse(_controllers['weight']!.text) ?? 0.0,
        color: _controllers['color']!.text.trim(),
        photoUrl: photoUrl ?? '',
        veterinarianInfo: _controllers['veterinarianInfo']!.text.trim(),
        emergencyContact: _controllers['emergencyContact']!.text.trim(),
        microchipNumber: _controllers['microchip']!.text.trim(),
        specialNeeds: _hasSpecialNeeds ? _controllers['notes']!.text.trim() : null,
        allergies: [],
        medications: [],
        lastUpdated: DateTime.now(),
      );

      await context.read<PetProvider>().addPet(newPet, newProfile);

      if (!mounted) return;
      
      _showSuccessSnackBar('Pet added successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackBar('Error adding pet: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToFirstError() {
    final FormState? form = _formKey.currentState;
    if (form == null) return;

    var hasError = false;
    form.validate();

    form.visitChildElements((element) {
      if (element.widget is FormField) {
        FormField<dynamic> field = element.widget as FormField<dynamic>;
        if (!field.isValid) {
          hasError = true;
          _scrollController.animateTo(
            element.renderObject!.getTransformTo(null).getTranslation().y - 100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          return;
        }
      }
    });

    if (!hasError) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _savePet,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Pet'),
          actions: [
            if (_hasUnsavedChanges)
              TextButton.icon(
                onPressed: _isLoading ? null : _savePet,
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
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    _buildBasicInfo(),
                    const SizedBox(height: 24),
                    _buildPhysicalInfo(),
                    const SizedBox(height: 24),
                    _buildAdditionalInfo(),
                    const SizedBox(height: 32),
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

  // Build methods for UI sections...
  [Previous UI building methods remain the same]

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
