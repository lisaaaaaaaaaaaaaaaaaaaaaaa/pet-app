import 'package:flutter/material.dart';
import '../models/symptom_record.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'common/custom_card.dart';

class SymptomTrackerCard extends StatelessWidget {
  final SymptomRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isExpanded;
  final EdgeInsets padding;

  const SymptomTrackerCard({
    Key? key,
    required this.record,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isExpanded = false,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              _buildSymptomsList(),
              if (record.notes != null && record.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildNotes(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormatter.formatDateTime(record.timestamp),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${record.symptoms.length} symptom${record.symptoms.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        _buildSeverityIndicator(),
        if (showActions) ...[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
            color: AppTheme.primaryColor,
            iconSize: 20,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            color: AppTheme.errorColor,
            iconSize: 20,
          ),
        ],
      ],
    );
  }

  Widget _buildSeverityIndicator() {
    final averageSeverity = record.symptoms.isEmpty
        ? 0.0
        : record.symptoms.map((s) => s.severity ?? 0.0).reduce((a, b) => a + b) /
            record.symptoms.length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getSeverityColor(averageSeverity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSeverityIcon(averageSeverity),
            size: 16,
            color: _getSeverityColor(averageSeverity),
          ),
          const SizedBox(width: 4),
          Text(
            averageSeverity.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getSeverityColor(averageSeverity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: record.symptoms.map((symptom) {
            return _buildSymptomChip(symptom);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomChip(Symptom symptom) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symptom.name,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          if (symptom.severity != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _getSeverityColor(symptom.severity!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                symptom.severity!.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (symptom.duration != null) ...[
            const SizedBox(width: 4),
            Text(
              _formatDuration(symptom.duration!),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          record.notes!,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(double severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 6) return Colors.orange;
    return Colors.red;
  }

  IconData _getSeverityIcon(double severity) {
    if (severity <= 3) return Icons.sentiment_satisfied;
    if (severity <= 6) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays >= 7) {
      return '${(duration.inDays / 7).floor()}w';
    }
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h';
    }
    return '${duration.inMinutes}m';
  }
}