import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pet_provider.dart';
import '../../models/medication.dart';
import '../../theme/app_theme.dart';

class MedicationManagerScreen extends StatefulWidget {
  const MedicationManagerScreen({Key? key}) : super(key: key);

  @override
  State<MedicationManagerScreen> createState() => _MedicationManagerScreenState();
}

class _MedicationManagerScreenState extends State<MedicationManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMedications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);
    try {
      await context.read<PetProvider>().loadMedications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading medications: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMedicationList('active'),
                      _buildMedicationList('upcoming'),
                      _buildMedicationList('completed'),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-medication'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Medication'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search medications',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildMedicationList(String status) {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        final medications = provider.getFilteredMedications(
          status: status,
          searchQuery: _searchQuery,
        );

        if (medications.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: _loadMedications,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              return _buildMedicationCard(medications[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showMedicationDetails(medication),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getMedicationColor(medication.type),
                    child: Icon(
                      _getMedicationIcon(medication.type),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${medication.dosage} ${medication.unit}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getNextDoseTime(medication),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        medication.frequency,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: medication.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getMedicationColor(medication.type),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(medication.progress * 100).toInt()}% Complete',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${medication.remainingDoses} doses remaining',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (medication.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  medication.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message;
    String submessage;

    switch (status) {
      case 'active':
        message = 'No active medications';
        submessage = 'Add medications to track them here';
        break;
      case 'upcoming':
        message = 'No upcoming medications';
        submessage = 'Scheduled medications will appear here';
        break;
      case 'completed':
        message = 'No completed medications';
        submessage = 'Completed medications will be listed here';
        break;
      default:
        message = 'No medications found';
        submessage = 'Try adjusting your search';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search'
                : submessage,
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showMedicationDetails(Medication medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildMedicationDetails(medication),
    );
  }

  Widget _buildMedicationDetails(Medication medication) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add medication details widgets here
            ],
          ),
        );
      },
    );
  }

  String _getNextDoseTime(Medication medication) {
    return DateFormat('h:mm a').format(medication.nextDose);
  }

  Color _getMedicationColor(String type) {
    switch (type.toLowerCase()) {
      case 'pill':
        return Colors.blue;
      case 'liquid':
        return Colors.purple;
      case 'injection':
        return Colors.red;
      case 'topical':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getMedicationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pill':
        return Icons.medication;
      case 'liquid':
        return Icons.local_drink;
      case 'injection':
        return Icons.vaccines;
      case 'topical':
        return Icons.healing;
      default:
        return Icons.medical_services;
    }
  }
}