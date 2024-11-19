// lib/screens/appointments/appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/pet_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/vet_appointment.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_helper.dart';
import '../../widgets/appointments/appointment_card.dart';
import '../../widgets/appointments/appointment_details_sheet.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/custom_calendar.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late ValueNotifier<List<VetAppointment>> _selectedEvents;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _loadAppointments();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final petProvider = context.read<PetProvider>();
      final appointmentProvider = context.read<AppointmentProvider>();
      
      final pet = petProvider.selectedPet;
      if (pet == null) {
        setState(() => _errorMessage = 'No pet selected');
        return;
      }

      await appointmentProvider.loadAppointments(pet.id);
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load appointments');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<VetAppointment> _getEventsForDay(DateTime day) {
    final pet = context.read<PetProvider>().selectedPet;
    if (pet == null) return [];

    return context.read<AppointmentProvider>()
        .getAppointmentsForDay(pet.id, day)
        .where((event) => !event.isCancelled)
        .toList();
  }

  // ... (continuing with more methods in the next part)
  // Continuing lib/screens/appointments/appointments_screen.dart

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  Future<void> _addAppointment() async {
    final pet = context.read<PetProvider>().selectedPet;
    if (pet == null) {
      _showErrorSnackBar('Please select a pet first');
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      '/add-appointment',
      arguments: {
        'petId': pet.id,
        'selectedDate': _selectedDay,
      },
    );

    if (result == true) {
      await _loadAppointments();
    }
  }

  Future<void> _showAppointmentDetails(VetAppointment appointment) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppointmentDetailsSheet(
        appointment: appointment,
        onEdit: () => _editAppointment(appointment),
        onCancel: () => _cancelAppointment(appointment),
        onReschedule: () => _rescheduleAppointment(appointment),
      ),
    );

    if (result == true) {
      await _loadAppointments();
    }
  }

  Future<void> _editAppointment(VetAppointment appointment) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit-appointment',
      arguments: appointment,
    );

    if (result == true) {
      await _loadAppointments();
    }
  }

  Future<void> _cancelAppointment(VetAppointment appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('YES'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<AppointmentProvider>().cancelAppointment(appointment.id);
      if (!mounted) return;
      
      _showSuccessSnackBar('Appointment cancelled successfully');
      await _loadAppointments();
    } catch (e) {
      _showErrorSnackBar('Failed to cancel appointment');
    }
  }

  Future<void> _rescheduleAppointment(VetAppointment appointment) async {
    final result = await Navigator.pushNamed(
      context,
      '/reschedule-appointment',
      arguments: appointment,
    );

    if (result == true) {
      await _loadAppointments();
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
  // Continuing lib/screens/appointments/appointments_screen.dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAppointment,
            tooltip: 'Add Appointment',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAppointment,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Book'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAppointments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildCalendar(),
        const Divider(height: 1),
        _buildEventsList(),
      ],
    );
  }

  Widget _buildCalendar() {
    return CustomCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      calendarFormat: _calendarFormat,
      eventLoader: _getEventsForDay,
      onDaySelected: _onDaySelected,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() => _calendarFormat = format);
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildEventsList() {
    return Expanded(
      child: ValueListenableBuilder<List<VetAppointment>>(
        valueListenable: _selectedEvents,
        builder: (context, appointments, _) {
          if (appointments.isEmpty) {
            return EmptyState(
              icon: Icons.event_busy,
              title: 'No Appointments',
              message: 'No appointments scheduled for ${DateFormat('MMMM d, y').format(_selectedDay)}',
              buttonText: 'Book Appointment',
              onButtonPressed: _addAppointment,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return AppointmentCard(
                appointment: appointment,
                onTap: () => _showAppointmentDetails(appointment),
                onEdit: () => _editAppointment(appointment),
                onCancel: () => _cancelAppointment(appointment),
                onReschedule: () => _rescheduleAppointment(appointment),
              );
            },
          );
        },
      ),
    );
  }
}

// Custom Widgets (in separate files)

class CustomCalendar extends StatelessWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final List<VetAppointment> Function(DateTime) eventLoader;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(CalendarFormat) onFormatChanged;
  final void Function(DateTime) onPageChanged;

  const CustomCalendar({
    Key? key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.eventLoader,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar<VetAppointment>(
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      calendarFormat: calendarFormat,
      eventLoader: eventLoader,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        markersMaxCount: 3,
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonShowsNext: false,
        titleCentered: true,
      ),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
    );
  }
}