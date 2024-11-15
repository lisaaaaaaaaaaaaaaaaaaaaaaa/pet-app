import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/pet_provider.dart';
import '../../models/medical_record.dart';
import '../../theme/app_theme.dart';
import '../../widgets/attachment_viewer.dart';
import '../../widgets/prescription_card.dart';
import '../../services/notification_service.dart';

class MedicalRecordDetailScreen extends StatefulWidget {
  final MedicalRecord record;

  const MedicalRecordDetailScreen({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  State<MedicalRecordDetailScreen> createState() => _MedicalRecordDetailScreenState();
}

class _MedicalRecordDetailScreenState extends State<MedicalRecordDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        if (widget.record.prescriptions.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildPrescriptions(),
                        ],
                        if (widget.record.attachments.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildAttachments(),
                        ],
                        const SizedBox(height: 24),
                        _buildNotes(),
                        if (widget.record.followUpDate != null) ...[
                          const SizedBox(height: 24),
                          _buildFollowUp(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: widget.record.followUpDate != null
          ? FloatingActionButton.extended(
              onPressed: () => _scheduleFollowUp(context),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Schedule Follow-up'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _getRecordColor(widget.record.type).withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getRecordColor(widget.record.type),
            child: Icon(
              _getRecordIcon(widget.record.type),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.record.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMMM dd, yyyy').format(widget.record.date),
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
              color: _getRecordColor(widget.record.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.record.type,
              style: TextStyle(
                color: _getRecordColor(widget.record.type),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... [Previous helper methods remain the same]

  Future<void> _editRecord(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit-medical-record',
      arguments: widget.record,
    );
    
    if (result == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<PetProvider>(context, listen: false)
            .loadMedicalRecords();
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _shareRecord(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<PetProvider>(context, listen: false)
          .shareMedicalRecord(widget.record);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing record: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'export':
        await _exportRecord(context);
        break;
      case 'delete':
        await _deleteRecord(context);
        break;
    }
  }

  Future<void> _exportRecord(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final pdfPath = await Provider.of<PetProvider>(context, listen: false)
          .exportMedicalRecordAsPdf(widget.record);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF exported to: $pdfPath')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting record: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteRecord(BuildContext context) async {
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<PetProvider>(context, listen: false)
            .deleteMedicalRecord(widget.record.id);
        
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting record: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _scheduleFollowUp(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      '/schedule-appointment',
      arguments: {'followUp': widget.record},
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Follow-up appointment scheduled')),
      );
    }
  }
}
