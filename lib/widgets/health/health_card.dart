import 'package:flutter/material.dart';
import '../../models/health_data.dart';
import '../../theme/app_theme.dart';
import '../common/custom_card.dart';

class HealthCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool isLoading;

  const HealthCard({
    Key? key,
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primaryColor;

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: cardColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showTrend && trendValue != null)
                      _buildTrendIndicator(trendValue!),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          unit!,
                          style: TextStyle(
                            fontSize: 16,
                            color: cardColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildTrendIndicator(double trend) {
    final isPositive = trend >= 0;
    final trendColor = isPositive ? AppTheme.successColor : AppTheme.errorColor;
    final trendIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            color: trendColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${trend.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Predefined health card variants
class WeightCard extends StatelessWidget {
  final double weight;
  final String unit;
  final double? trend;
  final VoidCallback? onTap;
  final bool isLoading;

  const WeightCard({
    Key? key,
    required this.weight,
    this.unit = 'kg',
    this.trend,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      title: 'Weight',
      value: weight.toString(),
      unit: unit,
      icon: Icons.monitor_weight_outlined,
      color: AppTheme.primaryColor,
      showTrend: true,
      trendValue: trend,
      onTap: onTap,
      isLoading: isLoading,
    );
  }
}

class CaloriesCard extends StatelessWidget {
  final int calories;
  final int targetCalories;
  final VoidCallback? onTap;
  final bool isLoading;

  const CaloriesCard({
    Key? key,
    required this.calories,
    required this.targetCalories,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (calories / targetCalories * 100).clamp(0, 100);
    
    return HealthCard(
      title: 'Daily Calories',
      value: calories.toString(),
      unit: 'cal',
      icon: Icons.local_fire_department_outlined,
      color: AppTheme.successColor,
      subtitle: 'Target: $targetCalories cal',
      showTrend: true,
      trendValue: progress,
      onTap: onTap,
      isLoading: isLoading,
    );
  }
}

class WaterIntakeCard extends StatelessWidget {
  final int glasses;
  final int targetGlasses;
  final VoidCallback? onTap;
  final bool isLoading;

  const WaterIntakeCard({
    Key? key,
    required this.glasses,
    required this.targetGlasses,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (glasses / targetGlasses * 100).clamp(0, 100);

    return HealthCard(
      title: 'Water Intake',
      value: glasses.toString(),
      unit: 'glasses',
      icon: Icons.water_drop_outlined,
      color: Colors.blue,
      subtitle: 'Target: $targetGlasses glasses',
      showTrend: true,
      trendValue: progress,
      onTap: onTap,
      isLoading: isLoading,
    );
  }
}