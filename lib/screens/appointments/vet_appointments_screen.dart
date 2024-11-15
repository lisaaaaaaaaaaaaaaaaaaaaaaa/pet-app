// lib/screens/vet/vet_appointment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class VetAppointmentScreen extends StatefulWidget {
  const VetAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<VetAppointmentScreen> createState() => _VetAppointmentScreenState();
}

class _VetAppointmentScreenState extends State<VetAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AppointmentProvider>().loadAppointments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading appointments: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAppointmentDetails(Appointment appointment) {
    Navigator.pushNamed(
      context,
      '/appointment-details',
      arguments: appointment,
    );
  }

  Future<void> _markAppointmentAsCompleted(Appointment appointment) async {
    try {
      await context
          .read<AppointmentProvider>()
          .markAppointmentAsCompleted(appointment.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment marked as completed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking appointment as completed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rescheduleAppointment(Appointment appointment) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: appointment.dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(appointment.dateTime),
      );

      if (pickedTime != null) {
        final DateTime newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        try {
          final updatedAppointment = appointment.copyWith(dateTime: newDateTime);
          await context
              .read<AppointmentProvider>()
              .updateAppointment(updatedAppointment);

          // Reschedule reminders
          await NotificationService().cancelAppointmentReminders(appointment);
          await NotificationService().scheduleAppointmentReminders(
            appointment: updatedAppointment,
            reminderMinutes: [60, 24 * 60, 7 * 24 * 60], // 1 hour, 1 day, 1 week
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment rescheduled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error rescheduling appointment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text(
            'Are you sure you want to delete this appointment with ${appointment.vetName}?'),
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
        await context.read<AppointmentProvider>().deleteAppointment(appointment.id);
        await NotificationService().cancelAppointmentReminders(appointment);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting appointment: $e'),
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
        title: const Text('Vet Appointments'),
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
                      _buildAppointmentList('upcoming'),
                      _buildAppointmentList('completed'),
                      _buildAppointmentList('all'),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAppointmentDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Appointment'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search appointments...',
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
  Widget _buildAppointmentList(String type) {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        final appointments = provider.getFilteredAppointments(
          type,
          _searchQuery,
        );

        if (appointments.isEmpty) {
          return _buildEmptyState(type);
        }

        return RefreshIndicator(
          onRefresh: _loadAppointments,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _buildAppointmentCard(appointment);
            },
          ),
        );
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final bool isPast = appointment.dateTime.isBefore(DateTime.now());
    final bool isToday = DateUtils.isSameDay(appointment.dateTime, DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetails(appointment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getAppointmentColor(appointment),
                    child: Icon(
                      _getAppointmentIcon(appointment),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.vetName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, y • h:mm a').format(appointment.dateTime),
                          style: TextStyle(
                            color: isPast && !appointment.isCompleted
                                ? Colors.red
                                : Colors.grey[600],
                            fontWeight:
                                isToday && !appointment.isCompleted ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!appointment.isCompleted)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'complete':
                            _markAppointmentAsCompleted(appointment);
                            break;
                          case 'reschedule':
                            _rescheduleAppointment(appointment);
                            break;
                          case 'edit':
                            _showEditAppointmentDialog(appointment);
                            break;
                          case 'delete':
                            _deleteAppointment(appointment);
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
              if (appointment.reason?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  'Reason: ${appointment.reason}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
              if (appointment.isCompleted) ...[
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
                      'Completed',
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
        message = 'No Upcoming Appointments';
        submessage = 'Schedule your next vet visit';
        icon = Icons.event_available;
        break;
      case 'completed':
        message = 'No Completed Appointments';
        submessage = 'Past appointments will appear here';
        icon = Icons.assignment_turned_in_outlined;
        break;
      default:
        message = 'No Appointments Found';
        submessage = 'Add appointments to track them here';
        icon = Icons.calendar_today;
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

  Color _getAppointmentColor(Appointment appointment) {
    if (appointment.isCompleted) return Colors.green;
    if (appointment.dateTime.isBefore(DateTime.now())) return Colors.red;
    if (DateUtils.isSameDay(appointment.dateTime, DateTime.now())) {
      return Colors.orange;
    }
    return AppColors.primary;
  }

  IconData _getAppointmentIcon(Appointment appointment) {
    if (appointment.isCompleted) return Icons.check;
    if (appointment.dateTime.isBefore(DateTime.now())) return Icons.warning;
    if (DateUtils.isSameDay(appointment.dateTime, DateTime.now())) {
      return Icons.access_time;
    }
    return Icons.medical_services;
  }

  void _showAddAppointmentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAppointmentForm(),
    );
  }

  void _showEditAppointmentDialog(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAppointmentForm(appointment: appointment),
    );
  }

  Widget _buildAppointmentForm({Appointment? appointment}) {
    final _formKey = GlobalKey<FormState>();
    final _vetNameController = TextEditingController(text: appointment?.vetName);
    final _reasonController = TextEditingController(text: appointment?.reason);
    DateTime _selectedDate = appointment?.dateTime ?? DateTime.now().add(const Duration(days: 1));
    TimeOfDay _selectedTime = TimeOfDay.fromDateTime(appointment?.dateTime ?? DateTime.now());
    bool _setReminder = true;
    List<int> _reminderMinutes = [60, 24 * 60, 7 * 24 * 60]; // 1 hour, 1 day, 1 week

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
                      Text(
                        appointment == null ? 'Add Appointment' : 'Edit Appointment',
                        style: const TextStyle(
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
                    controller: _vetNameController,
                    decoration: InputDecoration(
                      labelText: 'Veterinarian Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter veterinarian name';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date',
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null) {
                              setState(() => _selectedTime = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Time',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.access_time),
                            ),
                            child: Text(
                              _selectedTime.format(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason for Visit',
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
                    subtitle: const Text('Get notified before the appointment'),
                    value: _setReminder,
                    onChanged: (bool value) {
                      setState(() {
                        _setReminder = value;
                      });
                    },
                  ),
                  if (_setReminder) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('1 hour before'),
                          selected: _reminderMinutes.contains(60),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _reminderMinutes.add(60);
                              } else {
                                _reminderMinutes.remove(60);
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('1 day before'),
                          selected: _reminderMinutes.contains(24 * 60),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _reminderMinutes.add(24 * 60);
                              } else {
                                _reminderMinutes.remove(24 * 60);
                              }
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('1 week before'),
                          selected: _reminderMinutes.contains(7 * 24 * 60),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _reminderMinutes.add(7 * 24 * 60);
                              } else {
                                _reminderMinutes.remove(7 * 24 * 60);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final dateTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          );

                          final newAppointment = Appointment(
                            id: appointment?.id ??
                                DateTime.now().millisecondsSinceEpoch.toString(),
                            vetName: _vetNameController.text.trim(),
                            dateTime: dateTime,
                            reason: _reasonController.text.trim(),
                            isCompleted: false,
                          );

                          if (appointment == null) {
                            await context
                                .read<AppointmentProvider>()
                                .addAppointment(newAppointment);
                          } else {
                            await context
                                .read<AppointmentProvider>()
                                .updateAppointment(newAppointment);
                          }

                          if (_setReminder) {
                            await NotificationService()
                                .scheduleAppointmentReminders(
                              appointment: newAppointment,
                              reminderMinutes: _reminderMinutes,
                            );
                          }

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                appointment == null
                                    ? 'Appointment added successfully'
                                    : 'Appointment updated successfully',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
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
                    child: Text(
                      appointment == null ? 'Add Appointment' : 'Update Appointment',
                      style: const TextStyle(
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
}