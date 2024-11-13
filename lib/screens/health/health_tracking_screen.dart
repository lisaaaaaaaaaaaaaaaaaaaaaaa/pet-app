// lib/screens/health/health_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/health_metrics_provider.dart';
import '../../models/medical_record.dart';
import '../../models/medication.dart';
import '../../models/symptom_log.dart';
import '../../models/pain_record.dart';
import '../../theme/app_theme.dart';
import '../../widgets/health/health_metric_card.dart';
import '../../widgets/health/medication_list_item.dart';
import '../../widgets/health/symptom_card.dart';
import '../../widgets/health/medical_record_card.dart';
import '../../utils/date_formatter.dart';

class HealthTrackingScreen extends StatefulWidget {
  const HealthTrackingScreen({Key? key}) : super(key: key);

  @override
  State<HealthTrackingScreen> createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      final pet = context.read<PetProvider>().selectedPet;
      if (pet?.id != null) {
        await Future.wait([
          context.read<HealthMetricsProvider>().loadHealthMetrics(pet!.id!),
          _loadTabData(_tabController.index),
        ]);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTabData(int index) async {
    final pet = context.read<PetProvider>().selectedPet;
    if (pet?.id == null) return;

    switch (index) {
      case 0: // Overview
        await Future.wait([
          context.read<PetProvider>().loadMedications(pet.id!),
          context.read<PetProvider>().loadSymptoms(pet.id!),
        ]);
        break;
      case 1: // Medications
        await context.read<PetProvider>().loadMedications(pet.id!);
        break;
      case 2: // Symptoms
        await context.read<PetProvider>().loadSymptoms(pet.id!);
        break;
      case 3: // Records
        await context.read<PetProvider>().loadMedicalRecords(pet.id!);
        break;
    }
  }

  void _handleTabChange() {
    _loadTabData(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProvider>().selectedPet;
    final theme = Theme.of(context);

    if (pet == null) {
      return const Center(
        child: Text('No pet selected', style: TextStyle(fontSize: 16)),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(theme, pet.name),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _initializeData,
              child: _buildBody(pet.id!),
            ),
      floatingActionButton: _buildFAB(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, String petName) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health Tracking'),
          Text(
            petName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Medications'),
          Tab(text: 'Symptoms'),
          Tab(text: 'Records'),
        ],
        indicatorColor: theme.colorScheme.secondary,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
      ),
    );
  }

  // ... (continued in next part)
  // Continuing lib/screens/health/health_tracking_screen.dart

  Widget _buildBody(String petId) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(petId),
        _buildMedicationsTab(petId),
        _buildSymptomsTab(petId),
        _buildRecordsTab(petId),
      ],
    );
  }

  Widget _buildOverviewTab(String petId) {
    final healthMetrics = context.watch<HealthMetricsProvider>();
    final metrics = healthMetrics.getMetricsForPet(petId);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHealthSummaryCard(metrics),
              const SizedBox(height: 16),
              _buildUpcomingMedicationsCard(petId),
              const SizedBox(height: 16),
              _buildRecentSymptomsCard(petId),
              const SizedBox(height: 16),
              _buildHealthTrendsCard(petId),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthSummaryCard(List<HealthMetric> metrics) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Health Summary',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: _showHealthInfoDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHealthMetric(
              'Overall Health',
              _calculateOverallHealth(metrics),
              icon: Icons.favorite,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildHealthMetric(
              'Medication Adherence',
              _calculateMedicationAdherence(),
              icon: Icons.medication,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _buildHealthMetric(
              'Activity Level',
              _calculateActivityLevel(metrics),
              icon: Icons.directions_run,
              color: AppColors.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(
    String label,
    double value, {
    IconData? icon,
    Color? color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              '${(value * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? theme.colorScheme.primary,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingMedicationsCard(String petId) {
    final medications = context.watch<PetProvider>().getMedications(petId);
    final upcomingMeds = medications
        .where((med) => !med.isCompleted)
        .take(3)
        .toList();

    return HealthCard(
      title: 'Upcoming Medications',
      icon: Icons.medication_outlined,
      onTap: () => _tabController.animateTo(1),
      child: upcomingMeds.isEmpty
          ? const EmptyStateWidget(
              message: 'No upcoming medications',
              icon: Icons.medication_outlined,
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingMeds.length,
              itemBuilder: (context, index) => MedicationListItem(
                medication: upcomingMeds[index],
                onTap: () => _showMedicationDetails(upcomingMeds[index]),
                onStatusChanged: _toggleMedicationStatus,
              ),
            ),
    );
  }

  Widget _buildRecentSymptomsCard(String petId) {
    final symptoms = context.watch<PetProvider>().getSymptoms(petId);
    final recentSymptoms = symptoms.take(3).toList();

    return HealthCard(
      title: 'Recent Symptoms',
      icon: Icons.healing_outlined,
      onTap: () => _tabController.animateTo(2),
      child: recentSymptoms.isEmpty
          ? const EmptyStateWidget(
              message: 'No recent symptoms',
              icon: Icons.healing_outlined,
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentSymptoms.length,
              itemBuilder: (context, index) => SymptomListItem(
                symptom: recentSymptoms[index],
                onTap: () => _showSymptomDetails(recentSymptoms[index]),
              ),
            ),
    );
  }

  // ... (continued in next part)
  // Continuing lib/screens/health/health_tracking_screen.dart

  Widget _buildMedicationsTab(String petId) {
    final medications = context.watch<PetProvider>().getMedications(petId);
    
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: medications.isEmpty
              ? SliverFillRemaining(
                  child: EmptyStateWidget(
                    message: 'No medications added yet',
                    icon: Icons.medication_outlined,
                    buttonLabel: 'Add Medication',
                    onButtonPressed: _showAddMedicationDialog,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MedicationCard(
                        medication: medications[index],
                        onTap: () => _showMedicationDetails(medications[index]),
                        onStatusChanged: _toggleMedicationStatus,
                        onEdit: () => _showEditMedicationDialog(medications[index]),
                        onDelete: () => _deleteMedication(medications[index]),
                      ),
                    ),
                    childCount: medications.length,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSymptomsTab(String petId) {
    final symptoms = context.watch<PetProvider>().getSymptoms(petId);
    
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: symptoms.isEmpty
              ? SliverFillRemaining(
                  child: EmptyStateWidget(
                    message: 'No symptoms logged yet',
                    icon: Icons.healing_outlined,
                    buttonLabel: 'Log Symptom',
                    onButtonPressed: _showAddSymptomDialog,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SymptomCard(
                        symptom: symptoms[index],
                        onTap: () => _showSymptomDetails(symptoms[index]),
                        onEdit: () => _showEditSymptomDialog(symptoms[index]),
                        onDelete: () => _deleteSymptom(symptoms[index]),
                      ),
                    ),
                    childCount: symptoms.length,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRecordsTab(String petId) {
    final records = context.watch<PetProvider>().getMedicalRecords(petId);
    
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: records.isEmpty
              ? SliverFillRemaining(
                  child: EmptyStateWidget(
                    message: 'No medical records added yet',
                    icon: Icons.medical_information_outlined,
                    buttonLabel: 'Add Record',
                    onButtonPressed: _showAddMedicalRecordDialog,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MedicalRecordCard(
                        record: records[index],
                        onTap: () => _showMedicalRecordDetails(records[index]),
                        onEdit: () => _showEditMedicalRecordDialog(records[index]),
                        onDelete: () => _deleteMedicalRecord(records[index]),
                      ),
                    ),
                    childCount: records.length,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFAB(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddOptionsDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('Add New'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );
  }

  void _showAddOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.medication_outlined),
              title: const Text('Add Medication'),
              onTap: () {
                Navigator.pop(context);
                _showAddMedicationDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.healing_outlined),
              title: const Text('Log Symptom'),
              onTap: () {
                Navigator.pop(context);
                _showAddSymptomDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_information_outlined),
              title: const Text('Add Medical Record'),
              onTap: () {
                Navigator.pop(context);
                _showAddMedicalRecordDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ... (continued in next part with dialog implementations)
  // Continuing lib/screens/health/health_tracking_screen.dart

  Future<void> _showAddMedicationDialog() async {
    final pet = context.read<PetProvider>().selectedPet;
    if (pet == null) return;

    final result = await showDialog<Medication>(
      context: context,
      builder: (context) => MedicationFormDialog(
        title: 'Add Medication',
        petId: pet.id!,
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await context.read<PetProvider>().addMedication(
          petId: pet.id!,
          medication: result,
        );
        _showSuccessSnackBar('Medication added successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to add medication: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showEditMedicationDialog(Medication medication) async {
    final result = await showDialog<Medication>(
      context: context,
      builder: (context) => MedicationFormDialog(
        title: 'Edit Medication',
        petId: medication.petId,
        medication: medication,
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await context.read<PetProvider>().updateMedication(
          petId: medication.petId,
          medication: result,
        );
        _showSuccessSnackBar('Medication updated successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to update medication: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showAddSymptomDialog() async {
    final pet = context.read<PetProvider>().selectedPet;
    if (pet == null) return;

    final result = await showDialog<SymptomLog>(
      context: context,
      builder: (context) => SymptomLogDialog(
        title: 'Log Symptom',
        petId: pet.id!,
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await context.read<PetProvider>().addSymptom(
          petId: pet.id!,
          symptom: result,
        );
        _showSuccessSnackBar('Symptom logged successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to log symptom: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showMedicationDetails(Medication medication) async {
    await showDialog(
      context: context,
      builder: (context) => MedicationDetailsDialog(medication: medication),
    );
  }

  Future<void> _showSymptomDetails(SymptomLog symptom) async {
    await showDialog(
      context: context,
      builder: (context) => SymptomDetailsDialog(symptom: symptom),
    );
  }

  Future<void> _showMedicalRecordDetails(MedicalRecord record) async {
    await showDialog(
      context: context,
      builder: (context) => MedicalRecordDetailsDialog(record: record),
    );
  }

  Future<void> _toggleMedicationStatus(Medication medication) async {
    setState(() => _isLoading = true);
    try {
      await context.read<PetProvider>().updateMedication(
        petId: medication.petId,
        medication: medication.copyWith(
          isCompleted: !medication.isCompleted,
          completedAt: !medication.isCompleted ? DateTime.now() : null,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update medication status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMedication(Medication medication) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Medication',
      message: 'Are you sure you want to delete this medication?',
    );

    if (confirmed) {
      setState(() => _isLoading = true);
      try {
        await context.read<PetProvider>().deleteMedication(
          petId: medication.petId,
          medicationId: medication.id!,
        );
        _showSuccessSnackBar('Medication deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to delete medication: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Utility methods
  double _calculateOverallHealth(List<HealthMetric> metrics) {
    if (metrics.isEmpty) return 0.8; // Default value
    // Implement actual health calculation logic
    return 0.8;
  }

  double _calculateMedicationAdherence() {
    final pet = context.read<PetProvider>().selectedPet;
    if (pet == null) return 0.0;
    
    final medications = context.read<PetProvider>().getMedications(pet.id!);
    if (medications.isEmpty) return 1.0;

    final completedCount = medications.where((m) => m.isCompleted).length;
    return completedCount / medications.length;
  }

  double _calculateActivityLevel(List<HealthMetric> metrics) {
    if (metrics.isEmpty) return 0.7; // Default value
    // Implement actual activity calculation logic
    return 0.7;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHealthInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => const HealthInfoDialog(),
    );
  }
}