// lib/screens/care/care_log_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/care_provider.dart';
import '../../models/care_log.dart';
import '../../models/pet.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_helper.dart';
import '../../widgets/care/care_category_card.dart';
import '../../widgets/care/care_log_item.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';

class CareLogScreen extends StatefulWidget {
  const CareLogScreen({Key? key}) : super(key: key);

  @override
  State<CareLogScreen> createState() => _CareLogScreenState();
}

class _CareLogScreenState extends State<CareLogScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  final List<CareCategory> _categories = [
    CareCategory(
      id: 'medications',
      title: 'Medications',
      icon: Icons.medication,
      color: AppColors.blue,
      route: '/medications',
    ),
    CareCategory(
      id: 'feeding',
      title: 'Feeding',
      icon: Icons.restaurant,
      color: AppColors.orange,
      route: '/feeding',
    ),
    CareCategory(
      id: 'exercise',
      title: 'Exercise',
      icon: Icons.directions_walk,
      color: AppColors.green,
      route: '/exercise',
    ),
    CareCategory(
      id: 'grooming',
      title: 'Grooming',
      icon: Icons.cleaning_services,
      color: AppColors.purple,
      route: '/grooming',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCareLogs();
  }

  Future<void> _loadCareLogs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pet = context.read<PetProvider>().selectedPet;
      if (pet != null) {
        await context.read<CareProvider>().loadCareLogs(pet.id);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load care logs');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ... (continuing with more methods in the next part)
  // Continuing lib/screens/care/care_log_screen.dart

  Future<void> _navigateToCategory(CareCategory category) async {
    final pet = context.read<PetProvider>().selectedPet;
    if (pet == null) {
      _showErrorSnackBar('Please select a pet first');
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      category.route,
      arguments: {
        'petId': pet.id,
        'categoryId': category.id,
        'categoryTitle': category.title,
      },
    );

    if (result == true) {
      await _loadCareLogs();
    }
  }

  Future<void> _showLogDetails(CareLog log) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CareLogDetailsSheet(
        log: log,
        onEdit: () => _editCareLog(log),
        onDelete: () => _deleteCareLog(log),
      ),
    );

    if (result == true) {
      await _loadCareLogs();
    }
  }

  Future<void> _addCareLog() async {
    final pet = context.read<PetProvider>().selectedPet;
    if (pet == null) {
      _showErrorSnackBar('Please select a pet first');
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      '/add-care-log',
      arguments: {'petId': pet.id},
    );

    if (result == true) {
      await _loadCareLogs();
    }
  }

  Future<void> _editCareLog(CareLog log) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit-care-log',
      arguments: log,
    );

    if (result == true) {
      await _loadCareLogs();
    }
  }

  Future<void> _deleteCareLog(CareLog log) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Care Log'),
        content: const Text('Are you sure you want to delete this care log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await context.read<CareProvider>().deleteCareLog(log.id);
      _showSuccessSnackBar('Care log deleted successfully');
      await _loadCareLogs();
    } catch (e) {
      _showErrorSnackBar('Failed to delete care log');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ... (continuing with UI components in the next part)
  // Continuing lib/screens/care/care_log_screen.dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadCareLogs,
        child: Consumer<PetProvider>(
          builder: (context, petProvider, child) {
            final selectedPet = petProvider.selectedPet;

            if (selectedPet == null) {
              return const EmptyState(
                icon: Icons.pets,
                title: 'No Pet Selected',
                message: 'Please select a pet to view their care logs',
              );
            }

            if (_errorMessage != null) {
              return ErrorState(
                message: _errorMessage!,
                onRetry: _loadCareLogs,
              );
            }

            return _buildContent(selectedPet);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCareLog,
        icon: const Icon(Icons.add),
        label: const Text('Add Log'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildContent(Pet pet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(pet),
          const SizedBox(height: 24),
          _buildCategories(),
          const SizedBox(height: 24),
          _buildRecentLogs(),
        ],
      ),
    );
  }

  Widget _buildHeader(Pet pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Care Log',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tracking ${pet.name}\'s daily care',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.secondary,
              ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return CareCategoryCard(
              category: category,
              onTap: () => _navigateToCategory(category),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentLogs() {
    return Consumer<CareProvider>(
      builder: (context, careProvider, child) {
        final recentLogs = careProvider.recentLogs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Care Logs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/all-care-logs'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (recentLogs.isEmpty)
              const EmptyState(
                icon: Icons.note_alt,
                title: 'No Care Logs',
                message: 'Start tracking your pet\'s care by adding a log',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentLogs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final log = recentLogs[index];
                  return CareLogItem(
                    log: log,
                    onTap: () => _showLogDetails(log),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

// Custom Widgets (in separate files)

class CareCategoryCard extends StatelessWidget {
  final CareCategory category;
  final VoidCallback onTap;

  const CareCategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 40,
                color: category.color,
              ),
              const SizedBox(height: 12),
              Text(
                category.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CareLogItem extends StatelessWidget {
  final CareLog log;
  final VoidCallback onTap;

  const CareLogItem({
    Key? key,
    required this.log,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: log.category.color.withOpacity(0.1),
          child: Icon(
            log.category.icon,
            color: log.category.color,
          ),
        ),
        title: Text(log.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.description),
            const SizedBox(height: 4),
            Text(
              DateHelper.formatDateTime(log.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                  ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}