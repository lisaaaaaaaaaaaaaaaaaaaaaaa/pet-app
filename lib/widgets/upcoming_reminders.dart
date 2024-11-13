import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/pet.dart';

class UpcomingReminders extends StatelessWidget {
  const UpcomingReminders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReminderCard(
          title: 'Vet Appointment',
          description: 'Annual checkup with Dr. Smith',
          date: DateTime.now().add(const Duration(days: 2)),
          icon: Icons.medical_services_outlined,
          type: ReminderType.veterinary,
          onTap: () {
            Navigator.pushNamed(context, '/appointment-details');
          },
        ),
        const SizedBox(height: 12),
        ReminderCard(
          title: 'Medication Due',
          description: 'Heartworm Prevention',
          date: DateTime.now().add(const Duration(days: 1)),
          icon: Icons.medication_outlined,
          type: ReminderType.medication,
          onTap: () {
            Navigator.pushNamed(context, '/medication-details');
          },
        ),
        const SizedBox(height: 12),
        ReminderCard(
          title: 'Grooming Session',
          description: 'Professional grooming',
          date: DateTime.now().add(const Duration(days: 5)),
          icon: Icons.brush_outlined,
          type: ReminderType.grooming,
          onTap: () {
            Navigator.pushNamed(context, '/grooming-details');
          },
        ),
      ],
    );
  }
}

class ReminderCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime date;
  final IconData icon;
  final ReminderType type;
  final VoidCallback onTap;

  const ReminderCard({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    required this.type,
    required this.onTap,
  }) : super(key: key);

  Color _getColorForType(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return Colors.orange;
      case ReminderType.vaccination:
        return Colors.blue;
      case ReminderType.grooming:
        return Colors.purple;
      case ReminderType.veterinary:
        return Colors.red;
      case ReminderType.feeding:
        return Colors.green;
      case ReminderType.exercise:
        return Colors.teal;
      default:
        return AppTheme.primaryGreen;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return 'In $difference days';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(type);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.neutralGrey,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDate(date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    color: AppTheme.neutralGrey,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}