import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatsGrid extends StatelessWidget {
  final List<StatItem> items;
  final int crossAxisCount;
  final double spacing;
  final EdgeInsets padding;

  const StatsGrid({
    Key? key,
    required this.items,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: items.map((item) => _buildStatCard(item)).toList(),
      ),
    );
  }

  Widget _buildStatCard(StatItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: 32,
              color: item.color ?? AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            item.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: item.color ?? AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (item.trend != null) ...[
            const SizedBox(height: 8),
            _buildTrendIndicator(item.trend!),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(StatTrend trend) {
    final isPositive = trend.direction == TrendDirection.up;
    final color = isPositive ? Colors.green : Colors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${trend.value}%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class StatItem {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final StatTrend? trend;

  const StatItem({
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.trend,
  });
}

class StatTrend {
  final TrendDirection direction;
  final double value;

  const StatTrend({
    required this.direction,
    required this.value,
  });
}

enum TrendDirection {
  up,
  down,
}
