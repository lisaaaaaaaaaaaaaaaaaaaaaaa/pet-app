// lib/screens/vaccination/vaccination_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../providers/pet_provider.dart';
import '../../models/vaccination.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class VaccinationScheduleScreen extends StatefulWidget {
  const VaccinationScheduleScreen({Key? key}) : super(key: key);

  @override
  State<VaccinationScheduleScreen> createState() =>
      _VaccinationScheduleScreenState();
}

class _VaccinationScheduleScreenState extends State<VaccinationScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVaccinations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVaccinations() async {
    setState(() => _isLoading = true);
    try {
      await context.read<PetProvider>().loadVaccinations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading vaccinations: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showVaccinationDetails(Vaccination vaccination) {
    // Implement navigation to details screen
    Navigator.pushNamed(
      context,
      '/vaccination-details',
      arguments: vaccination,
    );
  }

  Future<void> _markVaccinationAsCompleted(Vaccination vaccination) async {
    try {
      await context.read<PetProvider>().markVaccinationAsCompleted(vaccination.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vaccination marked as completed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking vaccination as completed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rescheduleVaccination(Vaccination vaccination) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: vaccination.dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      try {
        final updatedVaccination = vaccination.copyWith(dueDate: picked);
        await context.read<PetProvider>().updateVaccination(updatedVaccination);
        
        // Reschedule reminders
        await NotificationService().cancelVaccinationReminders(vaccination);
        await NotificationService().scheduleVaccinationReminders(
          vaccination: updatedVaccination,
          reminderDays: [1, 3, 7],
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination rescheduled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rescheduling vaccination: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editVaccination(Vaccination vaccination) async {
    // Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality to be implemented'),
      ),
    );
  }

  Future<void> _deleteVaccination(Vaccination vaccination) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vaccination'),
        content: Text('Are you sure you want to delete ${vaccination.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await context.read<PetProvider>().deleteVaccination(vaccination.id);
        await NotificationService().cancelVaccinationReminders(vaccination);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting vaccination: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination Schedule'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
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
                      _buildVaccinationList('upcoming'),
                      _buildVaccinationList('completed'),
                      _buildVaccinationList('all'),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVaccinationDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Vaccination'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search vaccinations...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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

  Widget _buildVaccinationList(String type) {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        final vaccinations = provider.getFilteredVaccinations(
          type,
          _searchQuery,
        );

        if (vaccinations.isEmpty) {
          return _buildEmptyState(type);
        }

        return RefreshIndicator(
          onRefresh: _loadVaccinations,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vaccinations.length,
            itemBuilder: (context, index) {
              final vaccination = vaccinations[index];
              return _buildVaccinationCard(vaccination);
            },
          ),
        );
      },
    );
  }
  Widget _buildVaccinationCard(Vaccination vaccination) {
    final bool isOverdue = vaccination.dueDate.isBefore(DateTime.now()) &&
        !vaccination.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showVaccinationDetails(vaccination),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getVaccinationColor(vaccination),
                    child: Icon(
                      _getVaccinationIcon(vaccination),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccination.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Due: ${DateFormat('MMM d, y').format(vaccination.dueDate)}',
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.grey[600],
                            fontWeight: isOverdue ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!vaccination.isCompleted)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'complete':
                            _markVaccinationAsCompleted(vaccination);
                            break;
                          case 'reschedule':
                            _rescheduleVaccination(vaccination);
                            break;
                          case 'edit':
                            _editVaccination(vaccination);
                            break;
                          case 'delete':
                            _deleteVaccination(vaccination);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              Icon(Icons.check),
                              SizedBox(width: 8),
                              Text('Mark Complete'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'reschedule',
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 8),
                              Text('Reschedule'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (vaccination.notes?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  vaccination.notes!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
              if (vaccination.isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Completed on ${DateFormat('MMM d, y').format(vaccination.completedDate!)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    String message;
    String submessage;
    IconData icon;

    switch (type) {
      case 'upcoming':
        message = 'No Upcoming Vaccinations';
        submessage = 'All vaccinations are up to date';
        icon = Icons.check_circle_outline;
        break;
      case 'completed':
        message = 'No Completed Vaccinations';
        submessage = 'Mark vaccinations as complete when administered';
        icon = Icons.assignment_turned_in_outlined;
        break;
      default:
        message = 'No Vaccinations Found';
        submessage = 'Add vaccinations to track them here';
        icon = Icons.vaccines_outlined;
    }

    if (_searchQuery.isNotEmpty) {
      message = 'No Results Found';
      submessage = 'Try adjusting your search';
      icon = Icons.search_off_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              submessage,
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getVaccinationColor(Vaccination vaccination) {
    if (vaccination.isCompleted) return Colors.green;
    if (vaccination.dueDate.isBefore(DateTime.now())) return Colors.red;
    if (vaccination.dueDate.difference(DateTime.now()).inDays <= 7) {
      return Colors.orange;
    }
    return AppColors.primary;
  }

  IconData _getVaccinationIcon(Vaccination vaccination) {
    if (vaccination.isCompleted) return Icons.check;
    if (vaccination.dueDate.isBefore(DateTime.now())) return Icons.warning;
    return Icons.vaccines;
  }
}
  void _showAddVaccinationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddVaccinationForm(),
    );
  }

  Widget _buildAddVaccinationForm() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _notesController = TextEditingController();
    DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
    bool _setReminder = true;
    List<int> _reminderDays = [1, 3, 7];
    bool _isRecurring = false;
    int _recurringMonths = 12;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Vaccination',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Vaccination Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.vaccines),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vaccination name';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('MMM d, y').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Set Reminder'),
                    subtitle: const Text('Get notified before due date'),
                    value: _setReminder,
                    onChanged: (bool value) {
                      setState(() {
                        _setReminder = value;
                      });
                    },
                  ),
                  if (_setReminder) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Remind me before:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [1, 3, 7, 14, 30].map((days) {
                        final isSelected = _reminderDays.contains(days);
                        return FilterChip(
                          label: Text('$days ${days == 1 ? 'day' : 'days'}'),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _reminderDays.add(days);
                              } else {
                                _reminderDays.remove(days);
                              }
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Recurring Vaccination'),
                    subtitle: const Text('Automatically schedule next dose'),
                    value: _isRecurring,
                    onChanged: (bool value) {
                      setState(() {
                        _isRecurring = value;
                      });
                    },
                  ),
                  if (_isRecurring) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _recurringMonths,
                      decoration: InputDecoration(
                        labelText: 'Repeat Every',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [3, 6, 12, 24, 36]
                          .map((months) => DropdownMenuItem(
                                value: months,
                                child: Text('$months months'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _recurringMonths = value!;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final vaccination = Vaccination(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: _nameController.text.trim(),
                            dueDate: _selectedDate,
                            notes: _notesController.text.trim(),
                            isCompleted: false,
                            isRecurring: _isRecurring,
                            recurringMonths: _isRecurring ? _recurringMonths : null,
                          );

                          await context
                              .read<PetProvider>()
                              .addVaccination(vaccination);

                          if (_setReminder) {
                            await NotificationService().scheduleVaccinationReminders(
                              vaccination: vaccination,
                              reminderDays: _reminderDays,
                            );
                          }

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vaccination added successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error adding vaccination: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Vaccination',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }