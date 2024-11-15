import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/health_metrics.dart';
import '../../../providers/health_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_formatter.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_state.dart';
import '../../../widgets/common/loading_state.dart';
import '../dialogs/health_info_dialog.dart';

class OverviewTab extends StatelessWidget {
  final String petId;

  const OverviewTab({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingState(message: 'Loading health overview...');
        }

        if (provider.error != null) {
          return ErrorState(
            message: provider.error!,
            onRetry: () => provider.loadHealthMetrics(petId),
          );
        }

        if (provider.healthMetrics == null) {
          return const EmptyState(
            icon: Icons.favorite_outline,
            title: 'No Health Data',
            message: 'Start tracking your pet\'s health metrics',
          );
        }

        return _buildOverview(context, provider.healthMetrics!);
      },
    );
  }

  Widget _buildOverview(BuildContext context, HealthMetrics metrics) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildHealthScoreCard(metrics),
        const SizedBox(height: 16),
        _buildMetricsGrid(metrics),
        const SizedBox(height: 24),
        _buildRecentActivity(metrics),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Health Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const HealthInfoDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScoreCard(HealthMetrics metrics) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGreen,
              AppTheme.primaryGreen.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              'Overall Health Score',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  metrics.overallScore.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '/100',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getHealthStatus(metrics.overallScore),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(HealthMetrics metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(
          title: 'Medication Adherence',
          value: metrics.medicationAdherence,
          icon: Icons.medication_outlined,
          color: Colors.blue,
        ),
        _MetricCard(
          title: 'Activity Level',
          value: metrics.activityLevel,
          icon: Icons.directions_run_outlined,
          color: Colors.green,
        ),
        _MetricCard(
          title: 'Symptom Frequency',
          value: metrics.symptomFrequency,
          icon: Icons.healing_outlined,
          color: Colors.orange,
          isInverted: true,
        ),
        _MetricCard(
          title: 'Vet Visits',
          value: metrics.vetVisits,
          icon: Icons.local_hospital_outlined,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(HealthMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...metrics.recentActivities.map((activity) => _ActivityItem(
              activity: activity,
            )),
      ],
    );
  }

  String _getHealthStatus(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    return 'Needs Attention';
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final bool isInverted;

  const _MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isInverted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayValue = (isInverted ? (100 - value * 100) : value * 100).round();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
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
                ),
                const Spacer(),
                Text(
                  '$displayValue%',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: value,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final HealthActivity activity;

  const _ActivityItem({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getActivityColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getActivityIcon(),
                color: _getActivityColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormatter.formatDateTime(activity.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon() {
    switch (activity.type) {
      case ActivityType.medication:
        return Icons.medication_outlined;
      case ActivityType.symptom:
        return Icons.healing_outlined;
      case ActivityType.vetVisit:
        return Icons.local_hospital_outlined;
      case ActivityType.activity:
        return Icons.directions_run_outlined;
    }
  }

  Color _getActivityColor() {
    switch (activity.type) {
      case ActivityType.medication:
        return Colors.blue;
      case ActivityType.symptom:
        return Colors.orange;
      case ActivityType.vetVisit:
        return Colors.purple;
      case ActivityType.activity:
        return Colors.green;
    }
  }
}
