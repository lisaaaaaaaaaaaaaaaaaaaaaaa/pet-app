import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../../theme/app_theme.dart';

class MedicationListItem extends StatelessWidget {
  final Medication medication;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final bool showDivider;
  final bool showCheckbox;
  final bool isChecked;
  final Function(bool?)? onCheckChanged;

  const MedicationListItem({
    Key? key,
    required this.medication,
    this.isActive = true,
    this.onTap,
    this.onToggle,
    this.showDivider = true,
    this.showCheckbox = false,
    this.isChecked = false,
    this.onCheckChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                if (showCheckbox) ...[
                  Checkbox(
                    value: isChecked,
                    onChanged: onCheckChanged,
                    activeColor: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                ],
                _buildMedicationIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? AppTheme.textPrimaryColor
                              : AppTheme.textSecondaryColor,
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDosageText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor.withOpacity(
                            isActive ? 1.0 : 0.7,
                          ),
                        ),
                      ),
                      if (medication.schedule.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _buildNextDoseText(context),
                      ],
                    ],
                  ),
                ),
                if (onToggle != null)
                  Switch(
                    value: isActive,
                    onChanged: (_) => onToggle?.call(),
                    activeColor: AppTheme.primaryColor,
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: isActive
                        ? AppTheme.textSecondaryColor
                        : AppTheme.textSecondaryColor.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
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
        color: (isActive ? color : Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: isActive ? color : Colors.grey,
        size: 20,
      ),
    );
  }

  String _getDosageText() {
    return '${medication.dosage} ${medication.unit} - ${medication.frequency}';
  }

  Widget _buildNextDoseText(BuildContext context) {
    final nextDose = medication.getNextDose();
    if (nextDose == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time,
          size: 12,
          color: isActive
              ? AppTheme.primaryColor
              : AppTheme.textSecondaryColor.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          'Next: ${nextDose.format(context)}',
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.textSecondaryColor.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Variant for medication history
class MedicationHistoryItem extends StatelessWidget {
  final Medication medication;
  final DateTime takenAt;
  final bool wasLate;
  final bool wasSkipped;

  const MedicationHistoryItem({
    Key? key,
    required this.medication,
    required this.takenAt,
    this.wasLate = false,
    this.wasSkipped = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          _buildStatusIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${medication.dosage} ${medication.unit}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getTimeText(context),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getStatusText(),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    if (wasSkipped) {
      icon = Icons.close;
      color = AppTheme.errorColor;
    } else if (wasLate) {
      icon = Icons.warning;
      color = AppTheme.warningColor;
    } else {
      icon = Icons.check_circle;
      color = AppTheme.successColor;
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
        size: 20,
      ),
    );
  }

  String _getTimeText(BuildContext context) {
    return TimeOfDay.fromDateTime(takenAt).format(context);
  }

  String _getStatusText() {
    if (wasSkipped) return 'Skipped';
    if (wasLate) return 'Late';
    return 'On Time';
  }

  Color _getStatusColor() {
    if (wasSkipped) return AppTheme.errorColor;
    if (wasLate) return AppTheme.warningColor;
    return AppTheme.successColor;
  }
}