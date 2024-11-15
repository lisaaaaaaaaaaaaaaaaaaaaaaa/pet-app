import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';

class CustomDateTimePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final DateTime? selectedTime;
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay)? onTimeSelected;
  final bool showTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? dateHint;
  final String? timeHint;

  const CustomDateTimePicker({
    Key? key,
    this.selectedDate,
    this.selectedTime,
    required this.onDateSelected,
    this.onTimeSelected,
    this.showTime = true,
    this.firstDate,
    this.lastDate,
    this.dateHint,
    this.timeHint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildDatePicker(context),
        ),
        if (showTime && onTimeSelected != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildTimePicker(context),
          ),
        ],
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              selectedDate != null
                  ? DateFormatter.formatDate(selectedDate!)
                  : dateHint ?? 'Select Date',
              style: TextStyle(
                color: selectedDate != null
                    ? AppTheme.textPrimaryColor
                    : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return InkWell(
      onTap: () => _showTimePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              selectedTime != null
                  ? DateFormatter.formatTime(selectedTime!)
                  : timeHint ?? 'Select Time',
              style: TextStyle(
                color: selectedTime != null
                    ? AppTheme.textPrimaryColor
                    : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _showTimePicker(BuildContext context) async {
    if (onTimeSelected == null) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime != null
          ? TimeOfDay.fromDateTime(selectedTime!)
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onTimeSelected!(picked);
    }
  }
}
