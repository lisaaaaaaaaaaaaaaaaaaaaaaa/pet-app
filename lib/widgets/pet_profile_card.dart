import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class PetProfileCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onEdit;
  final VoidCallback? onViewMedical;
  final VoidCallback? onViewAppointments;
  final VoidCallback? onViewVaccinations;
  final bool showStats;
  final EdgeInsets padding;
  final double imageSize;

  const PetProfileCard({
    Key? key,
    required this.pet,
    this.onEdit,
    this.onViewMedical,
    this.onViewAppointments,
    this.onViewVaccinations,
    this.showStats = true,
    this.padding = const EdgeInsets.all(16),
    this.imageSize = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          _buildHeader(),
          if (showStats) ...[
            const Divider(),
            _buildStats(),
          ],
          const Divider(),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _buildProfileImage(),
              if (onEdit != null)
                _buildEditButton(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            pet.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${pet.breed} • ${pet.age} years old',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 3,
        ),
        image: DecorationImage(
          image: NetworkImage(pet.imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.edit, color: Colors.white),
        onPressed: onEdit,
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(),
          width: 1,
        ),
      ),
      child: Text(
        pet.status,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Weight', '${pet.weight} kg'),
          _buildStatItem('Gender', pet.gender),
          if (pet.microchipId != null)
            _buildStatItem('Microchip', pet.microchipId!),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          _buildActionButton(
            'Medical Records',
            Icons.medical_information,
            onViewMedical,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            'Appointments',
            Icons.calendar_today,
            onViewAppointments,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            'Vaccinations',
            Icons.vaccines,
            onViewVaccinations,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (pet.status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }
}