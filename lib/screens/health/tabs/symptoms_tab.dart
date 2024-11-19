import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/symptom_log.dart';
import '../../../providers/symptom_provider.dart';
import '../../../utils/date_formatter.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_state.dart';
import '../../../widgets/common/loading_state.dart';
import '../dialogs/symptom_form_dialog.dart';

class SymptomsTab extends StatelessWidget {
  final String petId;

  const SymptomsTab({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SymptomProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingState(message: 'Loading symptoms...');
        }

        if (provider.error != null) {
          return ErrorState(
            message: provider.error!,
            onRetry: () => provider.loadSymptoms(petId),
          );
        }

        if (provider.symptoms.isEmpty) {
          return EmptyState(
            icon: Icons.healing_outlined,
            title: 'No Symptoms',
            message: 'Track your pet\'s health symptoms',
            buttonText: 'Log Symptom',
            onPressed: () => _showAddSymptomDialog(context),
          );
        }

        return _buildSymptomsList(context, provider.symptoms);
      },
    );
  }

  Widget _buildSymptomsList(BuildContext context, List<SymptomLog> symptoms) {
    // Group symptoms by date
    final groupedSymptoms = <String, List<SymptomLog>>{};
    for (var symptom in symptoms) {
      final key = DateFormatter.formatDate(symptom.observedAt);
      groupedSymptoms.putIfAbsent(key, () => []).add(symptom);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedSymptoms.length + 1, // +1 for the summary card
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSummaryCard(symptoms);
        }
        final dateKey = groupedSymptoms.keys.elementAt(index - 1);
        final dateSymptoms = groupedSymptoms[dateKey]!;
        return _buildDateSection(context, dateKey, dateSymptoms);
      },
    );
  }

  Widget _buildSummaryCard(List<SymptomLog> symptoms) {
    final recentSymptoms = symptoms.where(
      (s) => s.observedAt.isAfter(
        DateTime.now().subtract(const Duration(days: 7)),
      ),
    ).toList();

    final hasWarning = recentSymptoms.any((s) => s.severity == 3);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasWarning ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: hasWarning ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  hasWarning ? 'Attention Needed' : 'Status Normal',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Last 7 days: ${recentSymptoms.length} symptom${recentSymptoms.length == 1 ? '' : 's'} recorded',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            if (hasWarning) ...[
              const SizedBox(height: 8),
              Text(
                'Severe symptoms detected. Consider consulting a veterinarian.',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    String dateKey,
    List<SymptomLog> symptoms,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: dateKey),
        const SizedBox(height: 8),
        ...symptoms.map((symptom) => _SymptomCard(
              symptom: symptom,
              onTap: () => _showEditSymptomDialog(context, symptom),
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showAddSymptomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SymptomFormDialog(
        title: 'Log Symptom',
        petId: petId,
      ),
    );
  }

  void _showEditSymptomDialog(BuildContext context, SymptomLog symptom) {
    showDialog(
      context: context,
      builder: (context) => SymptomFormDialog(
        title: 'Edit Symptom',
        petId: petId,
        symptom: symptom,
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

class _SymptomCard extends StatelessWidget {
  final SymptomLog symptom;
  final VoidCallback onTap;

  const _SymptomCard({
    Key? key,
    required this.symptom,
    required this.onTap,
  }) : super(key: key);

  Color _getSeverityColor() {
    switch (symptom.severity) {
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityLabel() {
    switch (symptom.severity) {
      case 1:
        return 'Mild';
      case 2:
        return 'Moderate';
      case 3:
        return 'Severe';
      default:
        return 'Unknown';
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
                      color: _getSeverityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.healing_outlined,
                      color: _getSeverityColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symptom.type,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getSeverityColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getSeverityLabel(),
                                style: TextStyle(
                                  color: _getSeverityColor(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormatter.formatTime(symptom.observedAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
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
              if (symptom.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  symptom.notes,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
