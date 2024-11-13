// lib/screens/pets/add_pet_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pet.dart';
import '../../models/pet_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/image_picker_bottom_sheet.dart';
import '../../utils/validators.dart';
import '../../utils/date_formatters.dart';
import '../../utils/image_helper.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final Map<String, TextEditingController> _controllers = {};
  
  String _selectedSpecies = 'Dog';
  String _selectedGender = 'Male';
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  final List<String> _speciesList = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  final List<String> _genderList = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = ['name', 'breed', 'weight', 'color', 'notes'];
    
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

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => const ImagePickerBottomSheet(),
    );

    if (source == null) return;

    try {
      final image = await ImageHelper.pickImage(source);
      if (image == null) return;

      final croppedImage = await ImageHelper.cropImage(
        image.path,
        cropStyle: CropStyle.circle,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
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

  // ... (continued in next part)
  // Continuing lib/screens/pets/add_pet_screen.dart

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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

      final String petId = DateTime.now().millisecondsSinceEpoch.toString();
      String? photoUrl;

      if (_selectedImage != null) {
        photoUrl = await context.read<PetProvider>().uploadPetImage(
          userId: userId,
          petId: petId,
          imageFile: _selectedImage!,
        );
      }

      final Pet newPet = Pet(
        id: petId,
        userId: userId,
        name: _controllers['name']!.text.trim(),
        species: _selectedSpecies,
        breed: _controllers['breed']!.text.trim(),
        dateOfBirth: _selectedDate,
        weight: double.tryParse(_controllers['weight']!.text) ?? 0.0,
        gender: _selectedGender,
        photoUrl: photoUrl ?? '',
        color: _controllers['color']!.text.trim(),
        notes: _controllers['notes']!.text.trim(),
        isActive: true,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      final PetProfile newProfile = PetProfile(
        id: petId,
        name: _controllers['name']!.text.trim(),
        species: _selectedSpecies,
        breed: _controllers['breed']!.text.trim(),
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
        weight: double.tryParse(_controllers['weight']!.text) ?? 0.0,
        color: _controllers['color']!.text.trim(),
        photoUrl: photoUrl ?? '',
        veterinarianInfo: '',
        emergencyContact: '',
        allergies: [],
        medications: [],
        vaccinations: [],
        medicalConditions: [],
        specialNeeds: '',
        microchipNumber: '',
        insuranceInfo: '',
        lastUpdated: DateTime.now(),
      );

      await context.read<PetProvider>().addPet(newPet, newProfile);
      
      if (!mounted) return;
      
      _showSuccessSnackBar('Pet added successfully!');
      Navigator.pop(context, petId);
    } catch (e) {
      _showErrorSnackBar('Error adding pet: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          onPressed: _savePet,
        ),
      ),
    );
  }

  // ... (continued in next part)
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
            onTap: _pickImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
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
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 18,
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: Colors.white,
                  onPressed: _pickImage,
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
            TextFormField(
              controller: _controllers['name'],
              decoration: const InputDecoration(
                labelText: 'Pet Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
              textCapitalization: TextCapitalization.words,
              validator: Validators.required('Please enter your pet\'s name'),
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
            TextFormField(
              controller: _controllers['breed'],
              decoration: const InputDecoration(
                labelText: 'Breed',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets_outlined),
              ),
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
                  child: TextFormField(
                    controller: _controllers['weight'],
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.number('Please enter a valid weight'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormatters.formatDate(_selectedDate)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
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
            TextFormField(
              controller: _controllers['color'],
              decoration: const InputDecoration(
                labelText: 'Color/Markings',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.palette_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controllers['notes'],
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 3,
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
      ),
      child: Text(_isLoading ? 'Adding Pet...' : 'Add Pet'),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}