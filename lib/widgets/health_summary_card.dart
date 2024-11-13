import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class HealthSummaryCard extends StatelessWidget {
  final String petName;
  final String? petImageUrl;
  final double weight;
  final String weightUnit;
  final DateTime lastCheckup;
  final List<VaccinationStatus> vaccinations;
  final List<HealthMetric> metrics;
  final List<HealthAlert>? alerts;
  final VoidCallback? onViewDetails;
  final VoidCallback? onAddRecord;
  final bool isLoading;

  const HealthSummaryCard({
    Key? key,
    required this.petName,
    this.petImageUrl,
    required this.weight,
    this.weightUnit = 'kg',
    required this.lastCheckup,
    required this.vaccinations,
    required this.metrics,
    this.alerts,
    this.onViewDetails,
    this.onAddRecord,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onViewDetails,
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
                      'Health Summary',
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
              ),
              if (onAddRecord != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primaryGreen,
                  onPressed: isLoading ? null : onAddRecord,
                ),
            ],
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            const SizedBox(height: 20),
            _buildMetricsGrid(context),
            const SizedBox(height: 16),
            _buildVaccinationStatus(context),
            if (alerts != null && alerts!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildHealthAlerts(context),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2,
      children: [
        _buildMetricTile(
          context,
          'Weight',
          '$weight $weightUnit',
          Icons.monitor_weight,
        ),
        _buildMetricTile(
          context,
          'Last Checkup',
          _formatDate(lastCheckup),
          Icons.calendar_today,
        ),
        ...metrics.map((metric) => _buildMetricTile(
              context,
              metric.name,
              metric.value,
              metric.icon,
            )),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
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
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralGrey,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationStatus(BuildContext context) {
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
          children: vaccinations.map((vaccination) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getVaccinationColor(vaccination.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getVaccinationIcon(vaccination.status),
                    size: 16,
                    color: _getVaccinationColor(vaccination.status),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    vaccination.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getVaccinationColor(vaccination.status),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHealthAlerts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Alerts',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.secondaryGreen,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ...alerts!.map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    alert.icon,
                    size: 16,
                    color: alert.color ?? AppTheme.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: alert.color ?? AppTheme.warning,
                          ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getVaccinationColor(VaccinationStatusType status) {
    switch (status) {
      case VaccinationStatusType.upToDate:
        return AppTheme.success;
      case VaccinationStatusType.due:
        return AppTheme.warning;
      case VaccinationStatusType.overdue:
        return AppTheme.error;
    }
  }

  IconData _getVaccinationIcon(VaccinationStatusType status) {
    switch (status) {
      case VaccinationStatusType.upToDate:
        return Icons.check_circle;
      case VaccinationStatusType.due:
        return Icons.access_time;
      case VaccinationStatusType.overdue:
        return Icons.warning;
    }
  }
}

class HealthMetric {
  final String name;
  final String value;
  final IconData icon;

  const HealthMetric({
    required this.name,
    required this.value,
    required this.icon,
  });
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

class HealthAlert {
  final String message;
  final IconData icon;
  final Color? color;
  final DateTime timestamp;

  const HealthAlert({
    required this.message,
    required this.icon,
    this.color,
    required this.timestamp,
  });
}