// lib/screens/pet/pet_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pet_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pet/profile_image_picker.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_overlay.dart';
import 'pet_profile_settings.dart';
import 'edit_pet_profile_screen.dart';

class PetProfileScreen extends StatefulWidget {
  final String petId;

  const PetProfileScreen({
    Key? key, 
    required this.petId,
  }) : super(key: key);

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPetProfile();
  }

  Future<void> _loadPetProfile() async {
    setState(() => _isLoading = true);
    try {
      await context.read<PetProvider>().loadPetProfile(widget.petId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load pet profile: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfileImage() async {
    try {
      final XFile? image = await ProfileImagePicker.show(
        context: context,
        currentImageUrl: context
            .read<PetProvider>()
            .selectedPetProfile
            ?.photoUrl,
      );

      if (image != null) {
        setState(() => _isLoading = true);
        await context.read<PetProvider>().updatePetProfileImage(
          petId: widget.petId,
          imageFile: File(image.path),
        );
        _showSuccessMessage('Profile image updated successfully');
      }
    } catch (e) {
      _showErrorMessage('Failed to update profile image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshProfile() async {
    await _loadPetProfile();
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetProfileSettings(petId: widget.petId),
      ),
    );
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPetProfileScreen(petId: widget.petId),
      ),
    ).then((_) => _refreshProfile());
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _refreshProfile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorView(
        message: _error!,
        onRetry: _refreshProfile,
      );
    }

    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final profile = petProvider.selectedPetProfile;

        if (profile == null && _isLoading) {
          return const LoadingOverlay();
        }

        if (profile == null) {
          return const Center(child: Text('Pet profile not found'));
        }

        return Scaffold(
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refreshProfile,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(profile),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProfileHeader(profile),
                          _buildInfoSection(profile),
                          _buildHealthSection(profile),
                          _buildVetSection(profile),
                          _buildEmergencySection(profile),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading) const LoadingOverlay(),
            ],
          ),
          floatingActionButton: _buildFAB(),
        );
      },
    );
  }

  // ... (continued in next part)
  // Continuing lib/screens/pet/pet_profile_screen.dart

  Widget _buildAppBar(PetProfile profile) {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildProfileImage(profile),
            _buildGradientOverlay(),
          ],
        ),
        title: Text(
          profile.name,
          style: const TextStyle(
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _navigateToEdit,
          tooltip: 'Edit Profile',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _navigateToSettings,
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildProfileImage(PetProfile profile) {
    return GestureDetector(
      onTap: _updateProfileImage,
      child: profile.photoUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: profile.photoUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.primary.withOpacity(0.1),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.pets,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            )
          : Container(
              color: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.pets,
                size: 50,
                color: AppColors.primary,
              ),
            ),
    );
  }

  Widget _buildGradientOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(PetProfile profile) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileStats(profile),
            const Divider(height: 32),
            _buildQuickActions(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats(PetProfile profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStat('Age', '${profile.age} years'),
        _buildStat('Weight', '${profile.weight} kg'),
        _buildStat('Gender', profile.gender),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(PetProfile profile) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildActionChip(
          label: 'Health Records',
          icon: Icons.medical_services,
          onTap: () => _navigateToHealthRecords(profile),
        ),
        _buildActionChip(
          label: 'Medications',
          icon: Icons.medication,
          onTap: () => _navigateToMedications(profile),
        ),
        _buildActionChip(
          label: 'Appointments',
          icon: Icons.calendar_today,
          onTap: () => _navigateToAppointments(profile),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editSection(title),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  // ... (continued in next part)
  // Continuing lib/screens/pet/pet_profile_screen.dart

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(height: 1.3),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showQuickActionsMenu,
      icon: const Icon(Icons.add),
      label: const Text('Add Record'),
    );
  }

  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Add Health Record'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddHealthRecord();
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('Add Medication'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddMedication();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Schedule Appointment'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddAppointment();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHealthRecords(PetProfile profile) {
    Navigator.pushNamed(
      context,
      '/pet/health-records',
      arguments: {'petId': profile.id},
    );
  }

  void _navigateToMedications(PetProfile profile) {
    Navigator.pushNamed(
      context,
      '/pet/medications',
      arguments: {'petId': profile.id},
    );
  }

  void _navigateToAppointments(PetProfile profile) {
    Navigator.pushNamed(
      context,
      '/pet/appointments',
      arguments: {'petId': profile.id},
    );
  }

  void _navigateToAddHealthRecord() {
    Navigator.pushNamed(
      context,
      '/pet/health-records/add',
      arguments: {'petId': widget.petId},
    );
  }

  void _navigateToAddMedication() {
    Navigator.pushNamed(
      context,
      '/pet/medications/add',
      arguments: {'petId': widget.petId},
    );
  }

  void _navigateToAddAppointment() {
    Navigator.pushNamed(
      context,
      '/pet/appointments/add',
      arguments: {'petId': widget.petId},
    );
  }

  void _editSection(String section) {
    Navigator.pushNamed(
      context,
      '/pet/edit-profile',
      arguments: {
        'petId': widget.petId,
        'section': section,
      },
    ).then((_) => _refreshProfile());
  }

  @override
  void dispose() {
    // Clean up any controllers or listeners here
    super.dispose();
  }
}

// Custom widgets that can be moved to separate files
class HealthCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;

  const HealthCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }
}