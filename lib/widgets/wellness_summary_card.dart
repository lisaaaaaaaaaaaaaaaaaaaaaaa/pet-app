import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class WellnessSummaryCard extends StatelessWidget {
  final String petName;
  final List<WellnessMetric> metrics;
  final List<WellnessAlert>? alerts;
  final DateTime? lastCheckup;
  final VoidCallback? onAddRecord;
  final Function(WellnessMetric)? onMetricTap;
  final bool isLoading;
  final String? veterinaryNotes;
  final Map<String, double>? wellnessScores;

  const WellnessSummaryCard({
    Key? key,
    required this.petName,
    required this.metrics,
    this.alerts,
    this.lastCheckup,
    this.onAddRecord,
    this.onMetricTap,
    this.isLoading = false,
    this.veterinaryNotes,
    this.wellnessScores,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    'Wellness Summary',
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
              if (onAddRecord != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primaryGreen,
                  onPressed: isLoading ? null : onAddRecord,
                ),
            ],
          ),
          if (lastCheckup != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last checkup: ${_formatDate(lastCheckup!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralGrey,
                  ),
            ),
          ],
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (alerts != null && alerts!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAlerts(context),
            ],
            const SizedBox(height: 16),
            _buildMetricsGrid(context),
            if (wellnessScores != null) ...[
              const SizedBox(height: 16),
              _buildWellnessScores(context),
            ],
            if (veterinaryNotes != null) ...[
              const SizedBox(height: 16),
              _buildVeterinaryNotes(context),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAlerts(BuildContext context) {
    return Column(
      children: alerts!.map((alert) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (alert.isUrgent ? AppTheme.error : AppTheme.warning)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  alert.icon ?? (alert.isUrgent ? Icons.warning : Icons.info),
                  color: alert.isUrgent ? AppTheme.error : AppTheme.warning,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: alert.isUrgent
                              ? AppTheme.error
                              : AppTheme.warning,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        return _buildMetricCard(context, metrics[index]);
      },
    );
  }

  Widget _buildMetricCard(BuildContext context, WellnessMetric metric) {
    return InkWell(
      onTap: onMetricTap != null ? () => onMetricTap!(metric) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              metric.icon,
              color: _getMetricColor(metric.status),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              metric.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.secondaryGreen,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              metric.value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getMetricColor(metric.status),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessScores(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wellness Scores',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.secondaryGreen,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ...wellnessScores!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${(entry.value * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: entry.value,
                  backgroundColor: AppTheme.neutralGrey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(entry.value),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildVeterinaryNotes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veterinary Notes',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.secondaryGreen,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            veterinaryNotes!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getMetricColor(WellnessStatus status) {
    switch (status) {
      case WellnessStatus.good:
        return AppTheme.success;
      case WellnessStatus.warning:
        return AppTheme.warning;
      case WellnessStatus.critical:
        return AppTheme.error;
      default:
        return AppTheme.neutralGrey;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return AppTheme.success;
    if (score >= 0.6) return AppTheme.warning;
    return AppTheme.error;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class WellnessMetric {
  final String name;
  final String value;
  final IconData icon;
  final WellnessStatus status;
  final String? notes;

  const WellnessMetric({
    required this.name,
    required this.value,
    required this.icon,
    required this.status,
    this.notes,
  });
}

class WellnessAlert {
  final String message;
  final bool isUrgent;
  final IconData? icon;
  final DateTime timestamp;

  const WellnessAlert({
    required this.message,
    this.isUrgent = false,
    this.icon,
    required this.timestamp,
  });
}

enum WellnessStatus {
  good,
  warning,
  critical,
  unknown,
}