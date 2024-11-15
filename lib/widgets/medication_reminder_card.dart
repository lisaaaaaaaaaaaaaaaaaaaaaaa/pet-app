import 'package:flutter/material.dart';
import '../models/medication_reminder.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'common/custom_card.dart';

class MedicationReminderCard extends StatelessWidget {
  final MedicationReminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTake;
  final VoidCallback? onSkip;
  final bool showActions;
  final bool isExpanded;

  const MedicationReminderCard({
    Key? key,
    required this.reminder,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onTake,
    this.onSkip,
    this.showActions = true,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIndicator(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.medicationName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTimeText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: _isOverdue()
                              ? AppTheme.errorColor
                              : AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showActions) ...[
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
              const SizedBox(height: 16),
              _buildDosageInfo(),
              const SizedBox(height: 16),
              _buildInstructions(),
              if (reminder.status == MedicationStatus.pending)
                _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color color;
    IconData icon;

    switch (reminder.status) {
      case MedicationStatus.taken:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case MedicationStatus.skipped:
        color = Colors.orange;
        icon = Icons.remove_circle;
        break;
      case MedicationStatus.missed:
        color = AppTheme.errorColor;
        icon = Icons.cancel;
        break;
      case MedicationStatus.pending:
        color = _isOverdue() ? AppTheme.errorColor : AppTheme.primaryColor;
        icon = Icons.medication;
        break;
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

  Widget _buildDosageInfo() {
    return Row(
      children: [
        _buildInfoItem(
          'Dosage',
          '${reminder.dosage} ${reminder.unit}',
          Icons.medical_information,
        ),
        const SizedBox(width: 24),
        _buildInfoItem(
          'Frequency',
          reminder.frequency,
          Icons.repeat,
        ),
        if (reminder.duration != null) ...[
          const SizedBox(width: 24),
          _buildInfoItem(
            'Duration',
            reminder.duration!,
            Icons.timer_outlined,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    if (reminder.instructions == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          reminder.instructions!,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onTake,
              icon: const Icon(Icons.check),
              label: const Text('Take'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onSkip,
              icon: const Icon(Icons.close),
              label: const Text('Skip'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeText() {
    final timeStr = DateFormatter.formatTime(reminder.scheduledTime);
    if (reminder.status == MedicationStatus.pending) {
      return _isOverdue()
          ? 'Overdue - $timeStr'
          : 'Scheduled for $timeStr';
    }
    return timeStr;
  }

  bool _isOverdue() {
    return reminder.status == MedicationStatus.pending &&
        reminder.scheduledTime.isBefore(DateTime.now());
  }
}