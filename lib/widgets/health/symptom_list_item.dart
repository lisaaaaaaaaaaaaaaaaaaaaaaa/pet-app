import 'package:flutter/material.dart';
import '../../models/symptom.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';

class SymptomListItem extends StatelessWidget {
  final Symptom symptom;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showTime;
  final bool showDate;
  final bool showSeverityDot;

  const SymptomListItem({
    Key? key,
    required this.symptom,
    this.onTap,
    this.showDivider = true,
    this.showTime = true,
    this.showDate = true,
    this.showSeverityDot = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                _buildSeverityIndicator(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symptom.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      if (symptom.description?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          symptom.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      _buildMetadata(),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildTimeStamp(),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildSeverityIndicator() {
    Color color;
    IconData icon;

    switch (symptom.severity) {
      case SymptomSeverity.mild:
        color = Colors.yellow.shade700;
        icon = Icons.brightness_1;
        break;
      case SymptomSeverity.moderate:
        color = Colors.orange;
        icon = Icons.brightness_1;
        break;
      case SymptomSeverity.severe:
        color = AppTheme.errorColor;
        icon = Icons.brightness_1;
        break;
      default:
        color = AppTheme.primaryColor;
        icon = Icons.brightness_1;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          if (showSeverityDot)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    final List<Widget> metadata = [];

    if (symptom.duration.isNotEmpty) {
      metadata.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_outlined,
              size: 12,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              symptom.duration,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    if (symptom.medications?.isNotEmpty ?? false) {
      if (metadata.isNotEmpty) {
        metadata.add(
          const SizedBox(width: 16),
        );
      }
      metadata.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.medication_outlined,
              size: 12,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${symptom.medications!.length} medications',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return Row(children: metadata);
  }

  Widget _buildTimeStamp() {
    if (!showTime && !showDate) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showTime)
          Text(
            DateFormatter.formatTime(symptom.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        if (showDate) ...[
          const SizedBox(height: 2),
          Text(
            DateFormatter.formatDate(symptom.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

// Grouped symptom list item
class GroupedSymptomListItem extends StatelessWidget {
  final String date;
  final List<Symptom> symptoms;
  final Function(Symptom) onSymptomTap;

  const GroupedSymptomListItem({
    Key? key,
    required this.date,
    required this.symptoms,
    required this.onSymptomTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ),
        ...symptoms.map((symptom) => SymptomListItem(
              symptom: symptom,
              onTap: () => onSymptomTap(symptom),
              showTime: true,
              showDate: false,
              showDivider: symptoms.last != symptom,
            )),
        const Divider(height: 1),
      ],
    );
  }
}