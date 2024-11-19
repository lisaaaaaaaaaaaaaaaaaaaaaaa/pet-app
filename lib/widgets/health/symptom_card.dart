import 'package:flutter/material.dart';
import '../../models/symptom.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../common/custom_card.dart';

class SymptomCard extends StatelessWidget {
  final Symptom symptom;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isExpanded;

  const SymptomCard({
    Key? key,
    required this.symptom,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
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
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDateTime(symptom.timestamp),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
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
          ),

          if (isExpanded || symptom.description != null) ...[
            const Divider(height: 24),
            // Details Section
            _buildDetailsSection(),
          ],

          // Duration and Severity Preview
          if (!isExpanded) ...[
            const Divider(height: 24),
            _buildPreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildSeverityIndicator() {
    Color color;
    String severityText;

    switch (symptom.severity) {
      case SymptomSeverity.mild:
        color = Colors.yellow;
        severityText = 'Mild';
        break;
      case SymptomSeverity.moderate:
        color = Colors.orange;
        severityText = 'Moderate';
        break;
      case SymptomSeverity.severe:
        color = AppTheme.errorColor;
        severityText = 'Severe';
        break;
      default:
        color = AppTheme.primaryColor;
        severityText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            severityText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (symptom.description != null) ...[
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            symptom.description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildFactorsGrid(),
        if (symptom.medications?.isNotEmpty ?? false) ...[
          const SizedBox(height: 16),
          _buildMedicationsList(),
        ],
      ],
    );
  }

  Widget _buildFactorsGrid() {
    final factors = <Widget>[];

    if (symptom.triggers?.isNotEmpty ?? false) {
      factors.add(_buildFactorChip(
        'Triggers',
        symptom.triggers!,
        Colors.orange,
      ));
    }

    if (symptom.relievingFactors?.isNotEmpty ?? false) {
      factors.add(_buildFactorChip(
        'Relieving Factors',
        symptom.relievingFactors!,
        Colors.green,
      ));
    }

    if (symptom.aggravatingFactors?.isNotEmpty ?? false) {
      factors.add(_buildFactorChip(
        'Aggravating Factors',
        symptom.aggravatingFactors!,
        Colors.red,
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: factors,
    );
  }

  Widget _buildFactorChip(String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            items.join(', '),
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Medications',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: symptom.medications!.map((medication) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                medication,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          'Duration: ${symptom.duration}',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}