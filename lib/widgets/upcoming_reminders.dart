import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'common/custom_card.dart';

class UpcomingReminders extends StatelessWidget {
  final List<Reminder> reminders;
  final VoidCallback? onViewAll;
  final Function(Reminder)? onReminderTap;
  final Function(Reminder)? onComplete;
  final Function(Reminder)? onSnooze;
  final int maxItems;
  final bool showHeader;
  final bool showEmpty;
  final EdgeInsets padding;

  const UpcomingReminders({
    Key? key,
    required this.reminders,
    this.onViewAll,
    this.onReminderTap,
    this.onComplete,
    this.onSnooze,
    this.maxItems = 3,
    this.showHeader = true,
    this.showEmpty = true,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedReminders = List<Reminder>.from(reminders)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    final upcomingReminders = sortedReminders.take(maxItems).toList();

    if (reminders.isEmpty && !showEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              _buildHeader(context),
            if (reminders.isEmpty)
              _buildEmptyState()
            else
              _buildRemindersList(upcomingReminders),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Upcoming Reminders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        if (onViewAll != null && reminders.isNotEmpty)
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.notifications_none,
              size: 48,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'No upcoming reminders',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList(List<Reminder> upcomingReminders) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingReminders.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return _ReminderItem(
          reminder: upcomingReminders[index],
          onTap: onReminderTap,
          onComplete: onComplete,
          onSnooze: onSnooze,
        );
      },
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final Reminder reminder;
  final Function(Reminder)? onTap;
  final Function(Reminder)? onComplete;
  final Function(Reminder)? onSnooze;

  const _ReminderItem({
    Key? key,
    required this.reminder,
    this.onTap,
    this.onComplete,
    this.onSnooze,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap != null ? () => onTap!(reminder) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeText(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _isOverdue()
                          ? AppTheme.errorColor
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (onComplete != null || onSnooze != null)
              _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getIconColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getReminderIcon(),
        color: _getIconColor(),
        size: 24,
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        if (onComplete != null)
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () => onComplete!(reminder),
            color: Colors.green,
            tooltip: 'Complete',
          ),
        if (onSnooze != null)
          IconButton(
            icon: const Icon(Icons.snooze_outlined),
            onPressed: () => onSnooze!(reminder),
            color: AppTheme.primaryColor,
            tooltip: 'Snooze',
          ),
      ],
    );
  }

  IconData _getReminderIcon() {
    switch (reminder.type.toLowerCase()) {
      case 'medication':
        return Icons.medication;
      case 'appointment':
        return Icons.calendar_today;
      case 'vaccination':
        return Icons.vaccines;
      case 'grooming':
        return Icons.pets;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (reminder.type.toLowerCase()) {
      case 'medication':
        return Colors.blue;
      case 'appointment':
        return Colors.purple;
      case 'vaccination':
        return Colors.green;
      case 'grooming':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getTimeText() {
    final timeStr = DateFormatter.formatDateTime(reminder.dateTime);
    if (_isOverdue()) {
      return 'Overdue - $timeStr';
    }
    return timeStr;
  }

  bool _isOverdue() {
    return reminder.dateTime.isBefore(DateTime.now());
  }
}