// lib/screens/appointments/appointment_booking_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment.dart';
import '../../models/clinic_hours.dart';
import '../../services/vet_appointment_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_helper.dart';
import '../../utils/validators.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/appointments/time_slot_grid.dart';
import '../../widgets/appointments/appointment_type_selector.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String petId;
  final String userId;
  final String veterinarianId;
  final String clinicId;
  final String? veterinarianName;
  final String? clinicName;

  const AppointmentBookingScreen({
    Key? key,
    required this.petId,
    required this.userId,
    required this.veterinarianId,
    required this.clinicId,
    this.veterinarianName,
    this.clinicName,
  }) : super(key: key);

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  final _scrollController = ScrollController();
  
  DateTime? _selectedDate;
  DateTime? _selectedTime;
  List<DateTime> _availableSlots = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _appointmentType = 'regular';
  bool _isEmergency = false;
  bool _hasUnsavedChanges = false;

  final Map<String, ClinicHours> _clinicHours = {
    'monday': ClinicHours(openTime: '09:00', closeTime: '17:00'),
    'tuesday': ClinicHours(openTime: '09:00', closeTime: '17:00'),
    'wednesday': ClinicHours(openTime: '09:00', closeTime: '17:00'),
    'thursday': ClinicHours(openTime: '09:00', closeTime: '17:00'),
    'friday': ClinicHours(openTime: '09:00', closeTime: '17:00'),
    'saturday': ClinicHours(openTime: '10:00', closeTime: '15:00'),
    'sunday': ClinicHours(isClosed: true),
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _reasonController.addListener(_onFieldChanged);
    _notesController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  // ... (continuing with more methods in the next part)
  // Continuing lib/screens/appointments/appointment_booking_screen.dart

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('KEEP EDITING'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DISCARD'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _loadAvailableSlots(DateTime date) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final slots = await context.read<AppointmentProvider>().getAvailableTimeSlots(
        veterinarianId: widget.veterinarianId,
        clinicId: widget.clinicId,
        date: date,
        duration: _getAppointmentDuration(),
        clinicHours: _clinicHours,
      );

      if (!mounted) return;

      setState(() {
        _availableSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Failed to load available slots. Please try again.';
        _isLoading = false;
      });
    }
  }

  int _getAppointmentDuration() {
    switch (_appointmentType) {
      case 'regular':
        return 30;
      case 'vaccination':
        return 15;
      case 'followup':
        return 20;
      default:
        return 30;
    }
  }

  Future<void> _bookAppointment() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Final availability check
      final isAvailable = await context.read<AppointmentProvider>().checkVeterinarianAvailability(
        veterinarianId: widget.veterinarianId,
        clinicId: widget.clinicId,
        proposedDate: _selectedTime!,
        duration: _getAppointmentDuration(),
      );

      if (!isAvailable) {
        _showErrorSnackBar('This slot is no longer available. Please select another time.');
        return;
      }

      // Create appointment
      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: widget.petId,
        userId: widget.userId,
        veterinarianId: widget.veterinarianId,
        clinicId: widget.clinicId,
        appointmentDate: _selectedTime!,
        appointmentType: _appointmentType,
        duration: _getAppointmentDuration(),
        reason: _reasonController.text.trim(),
        notes: _notesController.text.trim(),
        isEmergency: _isEmergency,
        status: 'scheduled',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final appointmentId = await context.read<AppointmentProvider>().createAppointment(appointment);

      if (!mounted) return;

      _showSuccessSnackBar('Appointment booked successfully!');
      Navigator.pop(context, appointmentId);
    } catch (e) {
      _showErrorSnackBar('Failed to book appointment: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      return false;
    }

    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _errorMessage = 'Please select both date and time';
      });
      return false;
    }

    if (_reasonController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a reason for the visit';
      });
      _scrollToField(_reasonController);
      return false;
    }

    return true;
  }

  void _scrollToFirstError() {
    final formState = _formKey.currentState!;
    if (!formState.validate()) {
      // Find the first error
      FormFieldState? firstErrorField;
      formState.forEach((field) {
        if (firstErrorField == null && !field.isValid) {
          firstErrorField = field;
        }
      });

      if (firstErrorField != null) {
        Scrollable.ensureVisible(
          firstErrorField!.context!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _scrollToField(TextEditingController controller) {
    final renderObject = context.findRenderObject();
    if (renderObject != null) {
      renderObject.showOnScreen(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _bookAppointment,
        ),
      ),
    );
  }

  // ... (continuing with UI components in the next part)
  // Continuing lib/screens/appointments/appointment_booking_screen.dart

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Appointment'),
          elevation: 0,
          actions: [
            if (_hasUnsavedChanges)
              TextButton.icon(
                onPressed: _isLoading ? null : _bookAppointment,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Book',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildClinicInfo(),
                    const SizedBox(height: 16),
                    _buildAppointmentType(),
                    const SizedBox(height: 16),
                    _buildDateSelection(),
                    const SizedBox(height: 16),
                    if (_selectedDate != null) _buildTimeSelection(),
                    const SizedBox(height: 16),
                    _buildReasonSection(),
                    const SizedBox(height: 16),
                    _buildNotesSection(),
                    const SizedBox(height: 16),
                    if (_errorMessage != null) _buildErrorMessage(),
                    const SizedBox(height: 16),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
            if (_isLoading) const LoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicInfo() {
    if (widget.clinicName == null && widget.veterinarianName == null) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.clinicName != null)
            ListTile(
              leading: const Icon(Icons.local_hospital),
              title: const Text('Clinic'),
              subtitle: Text(widget.clinicName!),
              dense: true,
            ),
          if (widget.veterinarianName != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Veterinarian'),
              subtitle: Text(widget.veterinarianName!),
              dense: true,
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentType() {
    return CustomCard(
      title: 'Appointment Type',
      child: Column(
        children: [
          AppointmentTypeSelector(
            value: _appointmentType,
            onChanged: (value) {
              setState(() {
                _appointmentType = value;
                _hasUnsavedChanges = true;
              });
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Emergency'),
            subtitle: const Text('Mark as emergency appointment'),
            value: _isEmergency,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _isEmergency = value;
                _hasUnsavedChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return CustomCard(
      title: 'Select Date',
      child: CalendarDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        onDateChanged: (date) {
          setState(() {
            _selectedDate = date;
            _selectedTime = null;
            _hasUnsavedChanges = true;
          });
          _loadAvailableSlots(date);
        },
        selectableDayPredicate: (date) {
          final dayName = DateFormat('EEEE').format(date).toLowerCase();
          return !_clinicHours[dayName]!.isClosed;
        },
      ),
    );
  }

  Widget _buildTimeSelection() {
    return CustomCard(
      title: 'Select Time',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TimeSlotGrid(
              availableSlots: _availableSlots,
              selectedTime: _selectedTime,
              onTimeSelected: (time) {
                setState(() {
                  _selectedTime = time;
                  _hasUnsavedChanges = true;
                });
              },
            ),
    );
  }

  Widget _buildReasonSection() {
    return CustomCard(
      title: 'Reason for Visit',
      child: CustomTextField(
        controller: _reasonController,
        maxLines: 3,
        hintText: 'Enter reason for visit...',
        validator: Validators.required('Please enter a reason for the visit'),
      ),
    );
  }

  Widget _buildNotesSection() {
    return CustomCard(
      title: 'Additional Notes',
      child: CustomTextField(
        controller: _notesController,
        maxLines: 3,
        hintText: 'Any additional notes...',
        helperText: 'Optional',
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _bookAppointment,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
      ),
      child: Text(
        _isLoading ? 'Booking...' : 'Book Appointment',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}