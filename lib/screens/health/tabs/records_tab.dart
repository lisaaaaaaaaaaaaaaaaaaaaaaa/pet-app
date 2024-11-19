import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/medical_record.dart';
import '../../../providers/medical_record_provider.dart';
import '../../../utils/date_formatter.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_state.dart';
import '../../../widgets/common/loading_state.dart';
import '../dialogs/medical_record_form_dialog.dart';

class RecordsTab extends StatelessWidget {
  final String petId;

  const RecordsTab({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalRecordProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingState(message: 'Loading medical records...');
        }

        if (provider.error != null) {
          return ErrorState(
            message: provider.error!,
            onRetry: () => provider.loadMedicalRecords(petId),
          );
        }

        if (provider.records.isEmpty) {
          return EmptyState(
            icon: Icons.medical_information_outlined,
            title: 'No Medical Records',
            message: 'Keep track of vet visits and treatments',
            buttonText: 'Add Record',
            onPressed: () => _showAddRecordDialog(context),
          );
        }

        return _buildRecordsList(context, provider.records);
      },
    );
  }

  Widget _buildRecordsList(BuildContext context, List<MedicalRecord> records) {
    // Group records by year and month
    final groupedRecords = <String, List<MedicalRecord>>{};
    for (var record in records) {
      final key = DateFormatter.formatYearMonth(record.date);
      groupedRecords.putIfAbsent(key, () => []).add(record);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedRecords.length,
      itemBuilder: (context, index) {
        final monthKey = groupedRecords.keys.elementAt(index);
        final monthRecords = groupedRecords[monthKey]!;
        return _buildMonthSection(context, monthKey, monthRecords);
      },
    );
  }

  Widget _buildMonthSection(
    BuildContext context,
    String monthKey,
    List<MedicalRecord> records,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: monthKey),
        const SizedBox(height: 8),
        ...records.map((record) => _RecordCard(
              record: record,
              onTap: () => _showEditRecordDialog(context, record),
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MedicalRecordFormDialog(
        title: 'Add Medical Record',
        petId: petId,
      ),
    );
  }

  void _showEditRecordDialog(BuildContext context, MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => MedicalRecordFormDialog(
        title: 'Edit Medical Record',
        petId: petId,
        record: record,
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

class _RecordCard extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback onTap;

  const _RecordCard({
    Key? key,
    required this.record,
    required this.onTap,
  }) : super(key: key);

  Color _getTypeColor() {
    switch (record.type.toLowerCase()) {
      case 'checkup':
        return Colors.blue;
      case 'vaccination':
        return Colors.green;
      case 'surgery':
        return Colors.red;
      case 'test results':
        return Colors.orange;
      case 'prescription':
        return Colors.purple;
      case 'emergency visit':
        return Colors.red;
      case 'dental care':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (record.type.toLowerCase()) {
      case 'checkup':
        return Icons.health_and_safety_outlined;
      case 'vaccination':
        return Icons.vaccines_outlined;
      case 'surgery':
        return Icons.medical_services_outlined;
      case 'test results':
        return Icons.science_outlined;
      case 'prescription':
        return Icons.receipt_outlined;
      case 'emergency visit':
        return Icons.emergency_outlined;
      case 'dental care':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.medical_information_outlined;
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
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
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
                                color: _getTypeColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                record.type,
                                style: TextStyle(
                                  color: _getTypeColor(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormatter.formatDate(record.date),
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
              if (record.provider.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.local_hospital_outlined,
                  record.provider,
                ),
              ],
              if (record.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.note_outlined,
                  record.notes,
                ),
              ],
              if (record.attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildAttachments(),
              ],
            ],
          ),
        ),
      ),
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

  Widget _buildAttachments() {
    return Row(
      children: [
        Icon(
          Icons.attach_file,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '${record.attachments.length} attachment${record.attachments.length == 1 ? '' : 's'}',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
