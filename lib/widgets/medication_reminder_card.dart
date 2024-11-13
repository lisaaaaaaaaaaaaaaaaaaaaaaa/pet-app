import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class MedicationReminderCard extends StatelessWidget {
  final String petName;
  final List<Medication> medications;
  final VoidCallback? onAddMedication;
  final Function(Medication)? onMarkComplete;
  final Function(Medication)? onViewDetails;
  final bool isLoading;
  final DateTime? nextDueTime;

  const MedicationReminderCard({
    Key? key,
    required this.petName,
    required this.medications,
    this.onAddMedication,
    this.onMarkComplete,
    this.onViewDetails,
    this.isLoading = false,
    this.nextDueTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upcomingMeds = medications.where((med) => !med.isCompleted).toList();
    final completedMeds = medications.where((med) => med.isCompleted).toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medication Reminders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    petName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryGreen,
                        ),
                  ),
                ],
              ),
              if (onAddMedication != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primaryGreen,
                  onPressed: isLoading ? null : onAddMedication,
                ),
            ],
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (nextDueTime != null) ...[
              const SizedBox(height: 16),
              _buildNextDueTime(context),
            ],
            if (upcomingMeds.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Upcoming',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.secondaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...upcomingMeds.map((med) => _buildMedicationItem(context, med)),
            ],
            if (completedMeds.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Completed Today',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.secondaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...completedMeds.take(3).map((med) => _buildMedicationItem(context, med)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildNextDueTime(BuildContext context) {
    final timeUntil = nextDueTime!.difference(DateTime.now());
    final isOverdue = timeUntil.isNegative;
    final color = isOverdue ? AppTheme.error : AppTheme.warning;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.access_time,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOverdue
                  ? 'Medication overdue!'
                  : 'Next medication due in ${_formatDuration(timeUntil)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(BuildContext context, Medication medication) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onViewDetails?.call(medication),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMedicationColor(medication).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMedicationIcon(medication),
                  color: _getMedicationColor(medication),
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medication.dosage} - ${medication.frequency}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.neutralGrey,
                          ),
                    ),
                  ],
                ),
              ),
              if (!medication.isCompleted && onMarkComplete != null)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: AppTheme.success,
                  onPressed: () => onMarkComplete?.call(medication),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMedicationColor(Medication medication) {
    if (medication.isCompleted) return AppTheme.success;
    if (medication.isOverdue) return AppTheme.error;
    return AppTheme.primaryGreen;
  }

  IconData _getMedicationIcon(Medication medication) {
    if (medication.isCompleted) return Icons.check_circle;
    if (medication.isOverdue) return Icons.warning;
    switch (medication.type) {
      case MedicationType.pill:
        return Icons.medication;
      case MedicationType.liquid:
        return Icons.water_drop;
      case MedicationType.injection:
        return Icons.vaccines;
      case MedicationType.topical:
        return Icons.healing;
      default:
        return Icons.medical_services;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final MedicationType type;
  final DateTime nextDue;
  final bool isCompleted;
  final bool isOverdue;
  final String? notes;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.type,
    required this.nextDue,
    this.isCompleted = false,
    this.isOverdue = false,
    this.notes,
  });
}

enum MedicationType {
  pill,
  liquid,
  injection,
  topical,
  other,
}