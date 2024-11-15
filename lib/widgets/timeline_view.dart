import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';

class TimelineView extends StatelessWidget {
  final List<TimelineItem> items;
  final double lineWidth;
  final Color? lineColor;
  final double dotSize;
  final EdgeInsets padding;

  const TimelineView({
    Key? key,
    required this.items,
    this.lineWidth = 2,
    this.lineColor,
    this.dotSize = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        final isLast = index == items.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeline(isLast),
              Expanded(
                child: _buildTimelineItem(item),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeline(bool isLast) {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lineColor ?? AppTheme.primaryColor,
            ),
          ),
          if (!isLast)
            Container(
              width: lineWidth,
              height: 80,
              color: (lineColor ?? AppTheme.primaryColor).withOpacity(0.2),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TimelineItem item) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              Text(
                DateFormatter.formatDateTime(item.dateTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          if (item.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              item.subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
          if (item.content != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                ),
              ),
              child: item.content,
            ),
          ],
        ],
      ),
    );
  }
}

class TimelineItem {
  final String title;
  final String? subtitle;
  final DateTime dateTime;
  final Widget? content;
  final Color? color;

  const TimelineItem({
    required this.title,
    this.subtitle,
    required this.dateTime,
    this.content,
    this.color,
  });
}
