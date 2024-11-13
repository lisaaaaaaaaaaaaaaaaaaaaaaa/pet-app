import 'package:flutter/material.dart';
import '../common/custom_card.dart';
import '../custom_button.dart';
import '../../models/diet_record.dart';
import '../../utils/date_formatter.dart';

class DietRecordDetailsDialog extends StatelessWidget {
  final DietRecord record;

  const DietRecordDetailsDialog({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: CustomCard(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Meal Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Meal', record.mealName),
              _buildDetailRow('Time', DateFormatter.formatDateTime(record.timestamp)),
              _buildDetailRow('Amount', '${record.amount} ${record.unit}'),
              _buildDetailRow('Calories', '${record.calories.round()} kcal'),
              if (record.protein != null)
                _buildDetailRow('Protein', '${record.protein!.round()}g'),
              if (record.fat != null)
                _buildDetailRow('Fat', '${record.fat!.round()}g'),
              if (record.fiber != null)
                _buildDetailRow('Fiber', '${record.fiber!.round()}g'),
              if (record.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(record.notes),
              ],
              const SizedBox(height: 24),
              CustomButton(
                onPressed: () => Navigator.pop(context),
                text: 'Close',
                type: ButtonType.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}