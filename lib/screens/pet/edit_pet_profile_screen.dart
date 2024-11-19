import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/pet_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/pet_profile.dart';
import '../../widgets/common/image_picker_bottom_sheet.dart';
import '../../utils/date_formatters.dart';

class EditPetProfileScreen extends StatefulWidget {
  final String petId;

  const EditPetProfileScreen({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  State<EditPetProfileScreen> createState() => _EditPetProfileScreenState();
}

class _EditPetProfileScreenState extends State<EditPetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final Map<String, TextEditingController> _controllers = {};
  
  String _selectedSpecies = 'Dog';
  String _selectedGender = 'Male';
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  String? _currentPhotoUrl;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  PetProfile? _originalProfile;

  final List<String> _speciesList = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  final List<String> _genderList = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _checkSubscription();
    _loadPetProfile();
  }

  void _checkSubscription() {
    final hasSubscription = context.read<SubscriptionProvider>().isSubscribed;
    if (!hasSubscription) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/subscription');
      });
    }
  }

  Future<void> _loadPetProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await context.read<PetProvider>().loadPetProfile(widget.petId);
      _originalProfile = profile;
      _initializeData(profile);
    } catch (e) {
      _showErrorSnackBar('Failed to load pet profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeData(PetProfile profile) {
    _selectedSpecies = profile.species;
    _selectedGender = profile.gender;
    _selectedDate = profile.dateOfBirth;
    _currentPhotoUrl = profile.photoUrl;

    final fields = {
      'name': profile.name,
      'breed': profile.breed,
      'weight': profile.weight.toString(),
      'color': profile.color,
      'notes': profile.specialNeeds ?? '',
    };
    
    fields.forEach((field, value) {
      _controllers[field] = TextEditingController(text: value)
        ..addListener(() {
          if (!_hasUnsavedChanges) {
            setState(() => _hasUnsavedChanges = true);
          }
        });
    });
  }

[Rest of the code you shared for EditPetProfileScreen]

  @override
  void dispose() {
    _scrollController.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
