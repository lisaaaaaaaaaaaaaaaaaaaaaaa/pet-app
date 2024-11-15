import 'package:flutter/material.dart';
import '../models/wellness_data.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class WellnessSummaryCard extends StatelessWidget {
  final WellnessData data;
  final VoidCallback? onTap;
  final bool showTrends;
  final bool showIcons;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final bool isExpanded;

  const WellnessSummaryCard({
    Key? key,
    required this.data,
    this.onTap,
    this.showTrends = true,
    this.showIcons = true,
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.height,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      width: width,
      height: height,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMetrics(),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Wellness Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        _buildOverallScore(),
      ],
    );
  }

  Widget _buildOverallScore() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getScoreColor(data.overallScore).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getScoreIcon(data.overallScore),
            size: 16,
            color: _getScoreColor(data.overallScore),
          ),
          const SizedBox(width: 4),
          Text(
            '${data.overallScore}/10',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getScoreColor(data.overallScore),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricItem(
          'Activity',
          data.activityScore,
          Icons.directions_run,
          data.activityTrend,
        ),
        _buildMetricItem(
          'Appetite',
          data.appetiteScore,
          Icons.restaurant,
          data.appetiteTrend,
        ),
        _buildMetricItem(
          'Sleep',
          data.sleepScore,
          Icons.bedtime,
          data.sleepTrend,
        ),
        _buildMetricItem(
          'Mood',
          data.moodScore,
          Icons.mood,
          data.moodTrend,
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    String label,
    int score,
    IconData icon,
    TrendDirection trend,
  ) {
    return Column(
      children: [
        if (showIcons)
          Icon(
            icon,
            color: _getScoreColor(score),
            size: 24,
          ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(score),
              ),
            ),
            if (showTrends) ...[
              const SizedBox(width: 4),
              _buildTrendIndicator(trend),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(TrendDirection trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case TrendDirection.up:
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case TrendDirection.down:
        icon = Icons.arrow_downward;
        color = Colors.red;
        break;
      case TrendDirection.stable:
        icon = Icons.arrow_forward;
        color = Colors.orange;
        break;
    }

    return Icon(
      icon,
      size: 12,
      color: color,
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('Notes', data.notes),
        if (data.concerns.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDetailItem('Concerns', data.concerns),
        ],
        if (data.recommendations.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDetailItem('Recommendations', data.recommendations),
        ],
      ],
    );
  }

  Widget _buildDetailItem(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 8) return Icons.sentiment_very_satisfied;
    if (score >= 6) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }
}