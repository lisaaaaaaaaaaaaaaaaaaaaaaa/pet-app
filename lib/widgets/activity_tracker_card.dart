import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class ActivityTrackerCard extends StatelessWidget {
  final Activity activity;
  final double progress;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool showActions;
  final bool expanded;

  const ActivityTrackerCard({
    Key? key,
    required this.activity,
    required this.progress,
    this.onTap,
    this.onEdit,
    this.showActions = true,
    this.expanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildActivityIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getProgressText(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showActions && onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    color: AppTheme.primaryColor,
                    iconSize: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(),
            if (expanded) ...[
              const SizedBox(height: 16),
              _buildDetailsGrid(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: activity.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        activity.icon,
        color: activity.color,
        size: 24,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(activity.color),
            minHeight: 8,
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: activity.color,
                  ),
                ),
                Text(
                  '${activity.current}/${activity.target} ${activity.unit}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsGrid() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildDetailItem(
          'Streak',
          '${activity.streak} days',
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildDetailItem(
          'Best',
          '${activity.best} ${activity.unit}',
          Icons.emoji_events,
          Colors.amber,
        ),
        if (activity.caloriesBurned != null)
          _buildDetailItem(
            'Calories',
            '${activity.caloriesBurned} cal',
            Icons.local_fire_department_outlined,
            Colors.red,
          ),
        if (activity.duration != null)
          _buildDetailItem(
            'Duration',
            activity.duration!,
            Icons.timer_outlined,
            Colors.blue,
          ),
      ],
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getProgressText() {
    if (activity.current >= activity.target) {
      return 'Goal achieved! 🎉';
    }
    final remaining = activity.target - activity.current;
    return '$remaining ${activity.unit} to go';
  }
}