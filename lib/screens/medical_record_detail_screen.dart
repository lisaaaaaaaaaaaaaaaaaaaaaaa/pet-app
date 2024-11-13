import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/pet_provider.dart';
import '../../models/medical_record.dart';
import '../../theme/app_theme.dart';

class MedicalRecordDetailScreen extends StatelessWidget {
  final MedicalRecord record;

  const MedicalRecordDetailScreen({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editRecord(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareRecord(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Export as PDF'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Record'),
                textStyle: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 24),
                  _buildDetails(),
                  if (record.prescriptions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildPrescriptions(),
                  ],
                  if (record.attachments.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildAttachments(),
                  ],
                  const SizedBox(height: 24),
                  _buildNotes(),
                  if (record.followUpDate != null) ...[
                    const SizedBox(height: 24),
                    _buildFollowUp(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: record.followUpDate != null
          ? FloatingActionButton.extended(
              onPressed: () => _scheduleFollowUp(context),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Schedule Follow-up'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _getRecordColor(record.type).withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getRecordColor(record.type),
            child: Icon(
              _getRecordIcon(record.type),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMMM dd, yyyy').format(record.date),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getRecordColor(record.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              record.type,
              style: TextStyle(
                color: _getRecordColor(record.type),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow('Veterinarian', record.vetName),
        _buildInfoRow('Clinic/Hospital', record.clinicName),
        _buildInfoRow('Cost', '\$${record.cost.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(record.description),
      ],
    );
  }

  Widget _buildPrescriptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prescriptions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: record.prescriptions.length,
          itemBuilder: (context, index) {
            final prescription = record.prescriptions[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.medication,
                    color: Colors.white,
                  ),
                ),
                title: Text(prescription.medication),
                subtitle: Text(prescription.instructions),
                trailing: Text(
                  prescription.duration,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAttachments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: record.attachments.length,
          itemBuilder: (context, index) {
            final attachment = record.attachments[index];
            return InkWell(
              onTap: () => _viewAttachment(context, attachment),
              child: _buildAttachmentThumbnail(attachment),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAttachmentThumbnail(String attachment) {
    final isImage = attachment.toLowerCase().endsWith('.jpg') ||
        attachment.toLowerCase().endsWith('.png');

    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          attachment,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            );
          },
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.insert_drive_file,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(record.notes ?? 'No notes available'),
      ],
    );
  }

  Widget _buildFollowUp() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Follow-up Required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Date: ${DateFormat('MMMM dd, yyyy').format(record.followUpDate!)}',
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRecordColor(String type) {
    switch (type.toLowerCase()) {
      case 'checkup':
        return Colors.blue;
      case 'vaccination':
        return Colors.green;
      case 'surgery':
        return Colors.red;
      case 'treatment':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getRecordIcon(String type) {
    switch (type.toLowerCase()) {
      case 'checkup':
        return Icons.health_and_safety;
      case 'vaccination':
        return Icons.vaccines;
      case 'surgery':
        return Icons.medical_services;
      case 'treatment':
        return Icons.healing;
      default:
        return Icons.description;
    }
  }

  Future<void> _editRecord(BuildContext context) async {
    // Navigate to edit screen
    Navigator.pushNamed(context, '/edit-medical-record', arguments: record);
  }

  Future<void> _shareRecord(BuildContext context) async {
    // Implement share functionality
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'export':
        // Implement export functionality
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Record'),
            content: const Text(
              'Are you sure you want to delete this medical record? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // Implement delete functionality
        }
        break;
    }
  }

  Future<void> _viewAttachment(BuildContext context, String attachment) async {
    if (await canLaunchUrl(Uri.parse(attachment))) {
      await launchUrl(Uri.parse(attachment));
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open attachment'),
        ),
      );
    }
  }

  Future<void> _scheduleFollowUp(BuildContext context) async {
    // Navigate to appointment scheduling screen
    Navigator.pushNamed(
      context,
      '/schedule-appointment',
      arguments: {'followUp': record},
    );
  }
}