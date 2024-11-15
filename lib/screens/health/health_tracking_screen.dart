import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'dialogs/add_options_dialog.dart';
import 'tabs/index.dart';

class HealthTrackingScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const HealthTrackingScreen({
    Key? key,
    required this.petId,
    required this.petName,
  }) : super(key: key);

  @override
  State<HealthTrackingScreen> createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      HapticFeedback.selectionClick();
    }
  }

  void _showAddOptionsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddOptionsDialog(petId: widget.petId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.petName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Health Tracking',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryGreen,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppTheme.primaryGreen,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.dashboard_outlined),
            text: 'Overview',
          ),
          Tab(
            icon: Icon(Icons.medication_outlined),
            text: 'Medications',
          ),
          Tab(
            icon: Icon(Icons.healing_outlined),
            text: 'Symptoms',
          ),
          Tab(
            icon: Icon(Icons.medical_information_outlined),
            text: 'Records',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        OverviewTab(petId: widget.petId),
        MedicationsTab(petId: widget.petId),
        SymptomsTab(petId: widget.petId),
        RecordsTab(petId: widget.petId),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showAddOptionsDialog,
      backgroundColor: AppTheme.primaryGreen,
      child: const Icon(Icons.add),
    );
  }
}
