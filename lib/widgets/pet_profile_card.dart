import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class PetProfileCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String breed;
  final String age;
  final String weight;
  final String gender;
  final List<String>? tags;
  final Map<String, String>? additionalInfo;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? ownerName;
  final String? microchipId;
  final List<VaccinationStatus>? vaccinations;

  const PetProfileCard({
    Key? key,
    required this.name,
    this.imageUrl,
    required this.breed,
    required this.age,
    required this.weight,
    required this.gender,
    this.tags,
    this.additionalInfo,
    this.onEdit,
    this.onTap,
    this.isLoading = false,
    this.ownerName,
    this.microchipId,
    this.vaccinations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: isLoading ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPetImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 8),
                    _buildBasicInfo(context),
                    if (tags != null && tags!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildTags(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (additionalInfo != null || microchipId != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildAdditionalInfo(context),
          ],
          if (vaccinations != null && vaccinations!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildVaccinations(context),
          ],
        ],
      ),
    );
  }

  Widget _buildPetImage() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.lightBlue.withOpacity(0.1),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.pets,
                    color: AppTheme.primaryGreen,
                    size: 40,
                  );
                },
              ),
            )
          : const Icon(
              Icons.pets,
              color: AppTheme.primaryGreen,
              size: 40,
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit),
            color: AppTheme.primaryGreen,
            onPressed: isLoading ? null : onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          breed,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.secondaryGreen,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildInfoChip(context, age),
            const SizedBox(width: 8),
            _buildInfoChip(context, weight),
            const SizedBox(width: 8),
            _buildInfoChip(
              context,
              gender,
              icon: gender.toLowerCase() == 'male'
                  ? Icons.male
                  : gender.toLowerCase() == 'female'
                      ? Icons.female
                      : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryGreen,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags!.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryGreen,
                ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ownerName != null)
          _buildInfoRow(context, 'Owner', ownerName!),
        if (microchipId != null) ...[
          if (ownerName != null) const SizedBox(height: 8),
          _buildInfoRow(context, 'Microchip ID', microchipId!),
        ],
        if (additionalInfo != null) ...[
          if (ownerName != null || microchipId != null)
            const SizedBox(height: 8),
          ...additionalInfo!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildInfoRow(context, entry.key, entry.value),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutralGrey,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildVaccinations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vaccinations',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.secondaryGreen,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vaccinations!.map((vaccination) {
            return _buildVaccinationChip(context, vaccination);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVaccinationChip(
      BuildContext context, VaccinationStatus vaccination) {
    final Color statusColor;
    final IconData statusIcon;

    switch (vaccination.status) {
      case VaccinationStatusType.upToDate:
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle;
        break;
      case VaccinationStatusType.due:
        statusColor = AppTheme.warning;
        statusIcon = Icons.access_time;
        break;
      case VaccinationStatusType.overdue:
        statusColor = AppTheme.error;
        statusIcon = Icons.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            vaccination.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                ),
          ),
        ],
      ),
    );
  }
}

class VaccinationStatus {
  final String name;
  final VaccinationStatusType status;
  final DateTime? dueDate;

  const VaccinationStatus({
    required this.name,
    required this.status,
    this.dueDate,
  });
}

enum VaccinationStatusType {
  upToDate,
  due,
  overdue,
}