import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class AppointmentCard extends StatelessWidget {
  final String appointmentId;
  final String petName;
  final String? petImageUrl;
  final String veterinarianName;
  final DateTime appointmentDate;
  final String appointmentType;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final bool isUpcoming;
  final String? notes;
  final bool isLoading;

  const AppointmentCard({
    Key? key,
    required this.appointmentId,
    required this.petName,
    this.petImageUrl,
    required this.veterinarianName,
    required this.appointmentDate,
    required this.appointmentType,
    required this.status,
    this.onTap,
    this.onCancel,
    this.onReschedule,
    this.isUpcoming = true,
    this.notes,
    this.isLoading = false,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.success;
      case 'pending':
        return AppTheme.warning;
      case 'cancelled':
        return AppTheme.error;
      case 'completed':
        return AppTheme.primaryGreen;
      default:
        return AppTheme.neutralGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(appointmentDate);
    final formattedTime = DateFormat('hh:mm a').format(appointmentDate);
    final statusColor = _getStatusColor();

    return CustomCard(
      onTap: isLoading ? null : onTap,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (petImageUrl != null)
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(petImageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightBlue.withOpacity(0.3),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: AppTheme.primaryGreen,
                    size: 30,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'with Dr. $veterinarianName',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryGreen,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.neutralGrey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.neutralGrey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedTime,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.medical_services,
                          size: 16,
                          color: AppTheme.neutralGrey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appointmentType,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (notes != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.note,
                            size: 16,
                            color: AppTheme.neutralGrey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              notes!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.neutralGrey,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (isUpcoming && status.toLowerCase() != 'cancelled') ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onReschedule != null)
                  TextButton.icon(
                    onPressed: isLoading ? null : onReschedule,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Reschedule'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                    ),
                  ),
                if (onCancel != null) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: isLoading ? null : onCancel,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}