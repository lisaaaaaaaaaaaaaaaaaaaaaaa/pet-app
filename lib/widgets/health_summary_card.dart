import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class HealthSummaryCard extends StatelessWidget {
  final String title;
  final List<HealthMetric> metrics;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? chart;
  final bool showDividers;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool expanded;
  final Widget? trailing;

  const HealthSummaryCard({
    Key? key,
    required this.title,
    required this.metrics,
    this.subtitle,
    this.onTap,
    this.chart,
    this.showDividers = true,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.expanded = false,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      color: backgroundColor,
      child: Padding(
        padding: padding,
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
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (chart != null && expanded) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: chart!,
              ),
            ],
            const SizedBox(height: 16),
            _buildMetricsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _MetricItem(metric: metric);
      },
    );
  }
}

class HealthMetric {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool isPositiveTrend;

  const HealthMetric({
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    required this.color,
    this.trend,
    this.isPositiveTrend = true,
  });
}

class _MetricItem extends StatelessWidget {
  final HealthMetric metric;

  const _MetricItem({
    Key? key,
    required this.metric,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: metric.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            metric.icon,
            color: metric.color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      metric.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    if (metric.unit != null) ...[
                      const SizedBox(width: 2),
                      Text(
                        metric.unit!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
                if (metric.trend != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        metric.isPositiveTrend
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 12,
                        color: metric.isPositiveTrend
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        metric.trend!,
                        style: TextStyle(
                          fontSize: 10,
                          color: metric.isPositiveTrend
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
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
    );
  }
}