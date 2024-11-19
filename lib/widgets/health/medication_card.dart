import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../../theme/app_theme.dart';
import '../common/custom_card.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isExpanded;
  final Function(bool)? onToggleReminder;

  const MedicationCard({
    Key? key,
    required this.medication,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isExpanded = false,
    this.onToggleReminder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildMedicationIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDosageText(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (showActions) ...[
                Switch(
                  value: medication.reminderEnabled,
                  onChanged: onToggleReminder,
                  activeColor: AppTheme.primaryColor,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                  color: AppTheme.primaryColor,
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: AppTheme.errorColor,
                  iconSize: 20,
                ),
              ],
            ],
          ),

          if (isExpanded) ...[
            const Divider(height: 24),
            // Details Section
            _buildDetailsSection(),
          ],

          // Schedule Preview
          if (!isExpanded && medication.schedule.isNotEmpty) ...[
            const Divider(height: 24),
            _buildSchedulePreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationIcon() {
    IconData icon;
    Color color;

    switch (medication.type) {
      case MedicationType.pill:
        icon = Icons.medication;
        color = Colors.blue;
        break;
      case MedicationType.liquid:
        icon = Icons.water_drop;
        color = Colors.purple;
        break;
      case MedicationType.injection:
        icon = Icons.vaccines;
        color = Colors.green;
        break;
      case MedicationType.inhaler:
        icon = Icons.air;
        color = Colors.orange;
        break;
      default:
        icon = Icons.medication;
        color = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  String _getDosageText() {
    return '${medication.dosage} ${medication.unit} - ${medication.frequency}';
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[
        const Text(
          'Instructions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          medication.instructions!,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
      ],
        const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildScheduleGrid(),
      ],
    );
  }

  Widget _buildScheduleGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: medication.schedule.map((time) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                time.format(context),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSchedulePreview() {
    final nextDose = medication.getNextDose();
    
    return Row(
      children: [
        const Icon(
          Icons.access_time,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          nextDose != null
              ? 'Next dose at ${nextDose.format(context)}'
              : 'No upcoming doses',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

// Compact variant for medication lists
class CompactMedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onTap;
  final bool isActive;

  const CompactMedicationCard({
    Key? key,
    required this.medication,
    this.onTap,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isActive ? AppTheme.primaryColor : Colors.grey)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.medication,
              color: isActive ? AppTheme.primaryColor : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? AppTheme.textPrimaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                ),
                Text(
                  _getDosageText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor.withOpacity(
                      isActive ? 1.0 : 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isActive
                ? AppTheme.textSecondaryColor
                : AppTheme.textSecondaryColor.withOpacity(0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  String _getDosageText() {
    return '${medication.dosage} ${medication.unit}';
  }
}