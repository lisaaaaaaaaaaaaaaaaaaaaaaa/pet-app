import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/medication.dart';
import '../../../providers/medication_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_formatter.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_state.dart';
import '../../../widgets/common/loading_state.dart';
import '../dialogs/medication_form_dialog.dart';

class MedicationsTab extends StatelessWidget {
  final String petId;

  const MedicationsTab({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingState(message: 'Loading medications...');
        }

        if (provider.error != null) {
          return ErrorState(
            message: provider.error!,
            onRetry: () => provider.loadMedications(petId),
          );
        }

        if (provider.medications.isEmpty) {
          return EmptyState(
            icon: Icons.medication_outlined,
            title: 'No Medications',
            message: 'Track your pet\'s medications and schedules',
            buttonText: 'Add Medication',
            onPressed: () => _showAddMedicationDialog(context),
          );
        }

        return _buildMedicationsList(context, provider.medications);
      },
    );
  }

  Widget _buildMedicationsList(BuildContext context, List<Medication> medications) {
    final activeMedications = medications.where((m) => !m.isCompleted).toList();
    final completedMedications = medications.where((m) => m.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (activeMedications.isNotEmpty) ...[
          const _SectionHeader(title: 'Active Medications'),
          const SizedBox(height: 8),
          ...activeMedications.map((medication) => _MedicationCard(
                medication: medication,
                onTap: () => _showEditMedicationDialog(context, medication),
              )),
          const SizedBox(height: 16),
        ],
        if (completedMedications.isNotEmpty) ...[
          const _SectionHeader(title: 'Completed Medications'),
          const SizedBox(height: 8),
          ...completedMedications.map((medication) => _MedicationCard(
                medication: medication,
                onTap: () => _showEditMedicationDialog(context, medication),
              )),
        ],
      ],
    );
  }

  void _showAddMedicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MedicationFormDialog(
        title: 'Add Medication',
        petId: petId,
      ),
    );
  }

  void _showEditMedicationDialog(BuildContext context, Medication medication) {
    showDialog(
      context: context,
      builder: (context) => MedicationFormDialog(
        title: 'Edit Medication',
        petId: petId,
        medication: medication,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onTap;

  const _MedicationCard({
    Key? key,
    required this.medication,
    required this.onTap,
  }) : super(key: key);

  String _getFrequencyLabel(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Once Daily';
      case 'twice_daily':
        return 'Twice Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'as_needed':
        return 'As Needed';
      default:
        return 'Custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medication_outlined,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          medication.dosage,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!medication.isCompleted)
                    _buildCompletionCheckbox(context),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.repeat,
                _getFrequencyLabel(medication.frequency),
              ),
              if (medication.hasReminder) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.notifications_outlined,
                  'Next: ${DateFormatter.formatDateTime(medication.nextDose)}',
                ),
              ],
              if (medication.instructions.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.info_outline,
                  medication.instructions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionCheckbox(BuildContext context) {
    return Checkbox(
      value: medication.isCompleted,
      activeColor: AppTheme.primaryGreen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      onChanged: (value) {
        if (value != null) {
          context.read<MedicationProvider>().toggleMedicationStatus(
                medication.copyWith(
                  isCompleted: value,
                  completedAt: value ? DateTime.now() : null,
                ),
              );
        }
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
