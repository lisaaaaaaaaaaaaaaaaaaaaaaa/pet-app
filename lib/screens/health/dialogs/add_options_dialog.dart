import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'medication_form_dialog.dart';
import 'symptom_form_dialog.dart';
import 'medical_record_form_dialog.dart';
import '../../../theme/app_theme.dart';

class AddOptionsDialog extends StatelessWidget {
  final String petId;

  const AddOptionsDialog({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildTitle(),
            _buildOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        'Add Health Record',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Column(
      children: [
        _buildOption(
          context,
          icon: Icons.medication_outlined,
          title: 'Add Medication',
          subtitle: 'Record medications and schedules',
          onTap: () => _showMedicationDialog(context),
        ),
        _buildDivider(),
        _buildOption(
          context,
          icon: Icons.healing_outlined,
          title: 'Log Symptom',
          subtitle: 'Track health symptoms and severity',
          onTap: () => _showSymptomDialog(context),
        ),
        _buildDivider(),
        _buildOption(
          context,
          icon: Icons.medical_information_outlined,
          title: 'Add Medical Record',
          subtitle: 'Store vet visits and treatments',
          onTap: () => _showMedicalRecordDialog(context),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 20,
      color: Colors.grey[200],
    );
  }

  void _showMedicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MedicationFormDialog(
        title: 'Add Medication',
        petId: petId,
      ),
    );
  }

  void _showSymptomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SymptomFormDialog(
        title: 'Log Symptom',
        petId: petId,
      ),
    );
  }

  void _showMedicalRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MedicalRecordFormDialog(
        title: 'Add Medical Record',
        petId: petId,
      ),
    );
  }
}
