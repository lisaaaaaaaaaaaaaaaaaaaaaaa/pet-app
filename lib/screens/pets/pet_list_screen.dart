// lib/screens/pets/pet_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../models/pet.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pets/pet_list_item.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_overlay.dart';
import 'add_pet_screen.dart';
import 'pet_profile_screen.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({Key? key}) : super(key: key);

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<PetProvider>().loadPets();
    } catch (e) {
      setState(() => _error = 'Failed to load pets: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPets() async {
    try {
      await context.read<PetProvider>().loadPets(forceRefresh: true);
    } catch (e) {
      _showErrorSnackBar('Failed to refresh: $e');
    }
  }

  Future<void> _navigateToAddPet() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPetScreen(),
      ),
    );

    if (result != null) {
      _showSuccessSnackBar('Pet added successfully!');
    }
  }

  void _navigateToPetProfile(String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetProfileScreen(petId: petId),
      ),
    );
  }

  Future<void> _togglePetStatus(Pet pet) async {
    try {
      await context.read<PetProvider>().togglePetStatus(
        petId: pet.id!,
        isActive: !pet.isActive,
      );
      
      _showSuccessSnackBar(
        pet.isActive ? 'Pet archived' : 'Pet activated',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update pet status: $e');
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
          onPressed: _refreshPets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter pets',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return ErrorView(
        message: _error!,
        onRetry: _loadPets,
      );
    }

    return Stack(
      children: [
        Consumer<PetProvider>(
          builder: (context, petProvider, child) {
            final pets = petProvider.pets;

            if (pets.isEmpty && !_isLoading) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: _refreshPets,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: pets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => PetListItem(
                  pet: pets[index],
                  onTap: () => _navigateToPetProfile(pets[index].id!),
                  onToggleStatus: () => _togglePetStatus(pets[index]),
                ),
              ),
            );
          },
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.pets,
      title: 'No Pets Yet',
      message: 'Add your first pet to get started!',
      buttonText: 'Add Pet',
      onAction: _navigateToAddPet,
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('All Pets'),
              onTap: () {
                context.read<PetProvider>().setFilter(PetFilter.all);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Active Pets'),
              onTap: () {
                context.read<PetProvider>().setFilter(PetFilter.active);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archived Pets'),
              onTap: () {
                context.read<PetProvider>().setFilter(PetFilter.archived);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}