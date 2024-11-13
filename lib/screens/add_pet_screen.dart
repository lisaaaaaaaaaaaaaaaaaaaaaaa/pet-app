// lib/screens/pets/add_pet_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../providers/pet_provider.dart';
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
    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = [
      'name',
      'breed',
      'weight',
      'color',
      'microchip',
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

  // ... (continuing with more methods in the next part)
  // Continuing lib/screens/pets/add_pet_screen.dart

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

  void _scrollToFirstError() {
    final formState = _formKey.currentState!;
    if (!formState.validate()) {
      // Find the first error
      FormFieldState? firstErrorField;
      formState.forEach((field) {
        if (firstErrorField == null && !field.isValid) {
          firstErrorField = field;
        }
      });

      if (firstErrorField != null) {
        Scrollable.ensureVisible(
          firstErrorField!.context!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final petProvider = context.read<PetProvider>();
      final storageService = StorageService();
      final userId = context.read<AuthProvider>().currentUser?.id;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Create unique ID for new pet
      final String petId = DateTime.now().millisecondsSinceEpoch.toString();
      String photoUrl = '';

      // Upload image if selected
      if (_selectedImage != null) {
        photoUrl = await storageService.uploadPetImage(
          _selectedImage!,
          petId,
          onProgress: (progress) {
            // TODO: Show upload progress
          },
        );
      }

      // Create Pet object
      final Pet newPet = Pet(
        id: petId,
        userId: userId,
        name: _controllers['name']!.text.trim(),
        species: _selectedSpecies,
        breed: _controllers['breed']!.text.trim(),
        dateOfBirth: _dateOfBirth,
        weight: double.parse(_controllers['weight']!.text),
        gender: _selectedGender,
        photoUrl: photoUrl,
        isActive: true,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      // Create PetProfile object
      final PetProfile newProfile = PetProfile(
        id: petId,
        name: _controllers['name']!.text.trim(),
        species: _selectedSpecies,
        breed: _controllers['breed']!.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _selectedGender,
        weight: double.parse(_controllers['weight']!.text),
        color: _controllers['color']!.text.trim(),
        microchipNumber: _controllers['microchip']!.text.trim(),
        photoUrl: photoUrl,
        allergies: [],
        medicalConditions: [],
        medications: [],
        dietaryRestrictions: {},
        veterinarianInfo: '',
        emergencyContact: '',
        insuranceInfo: '',
        vaccinations: [],
        notes: _controllers['notes']!.text.trim(),
        hasSpecialNeeds: _hasSpecialNeeds,
        lastUpdated: DateTime.now(),
      );

      // Save pet and profile
      await petProvider.addPet(newPet, newProfile);

      if (!mounted) return;
      
      _showSuccessSnackBar('Pet added successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackBar('Error adding pet: $e');
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
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _savePet,
        ),
      ),
    );
  }

  // ... (continuing with UI components in the next part)
  // Continuing lib/screens/pets/add_pet_screen.dart

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

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showImagePicker,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          if (_selectedImage != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _showImagePicker,
                ),
              ),
            ),
        ],
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
              controller: _controllers['name']!,
              label: 'Pet Name',
              prefixIcon: Icons.pets,
              validator: Validators.required('Please enter a name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Species',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _speciesList.map((species) => DropdownMenuItem(
                value: species,
                child: Text(species),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpecies = value!;
                  _hasUnsavedChanges = true;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _controllers['breed']!,
              label: 'Breed',
              prefixIcon: Icons.pets_outlined,
              helperText: 'Optional',
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Physical Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: _genderList.map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _controllers['weight']!,
                    label: 'Weight (kg)',
                    prefixIcon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                    validator: Validators.compose([
                      Validators.required('Please enter weight'),
                      Validators.number('Please enter a valid number'),
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _controllers['color']!,
              label: 'Color/Markings',
              prefixIcon: Icons.palette_outlined,
              helperText: 'Optional',
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DatePickerField(
              label: 'Date of Birth',
              date: _dateOfBirth,
              onTap: _selectDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _controllers['microchip']!,
              label: 'Microchip Number',
              prefixIcon: Icons.qr_code,
              helperText: 'Optional',
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Has Special Needs'),
              subtitle: const Text('Requires special care or attention'),
              value: _hasSpecialNeeds,
              onChanged: (value) {
                setState(() {
                  _hasSpecialNeeds = value;
                  _hasUnsavedChanges = true;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _controllers['notes']!,
              label: 'Additional Notes',
              prefixIcon: Icons.note_outlined,
              maxLines: 3,
              helperText: 'Optional',
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _savePet,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
      ),
      child: Text(
        _isLoading ? 'Adding Pet...' : 'Add Pet',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}