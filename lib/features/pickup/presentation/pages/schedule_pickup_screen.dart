import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_state.dart';

/// Schedule Pickup Screen — Calendar-based scheduling with time slots.
///
/// Features:
/// - 14-day calendar view
/// - 2-hour time slot selection
/// - Recurring pickup toggle
/// - Waste category & weight
class SchedulePickupScreen extends StatefulWidget {
  const SchedulePickupScreen({super.key});

  @override
  State<SchedulePickupScreen> createState() => _SchedulePickupScreenState();
}

class _SchedulePickupScreenState extends State<SchedulePickupScreen> {
  final _addressController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  PickupTimeSlot? _selectedTimeSlot;
  WasteCategory? _selectedCategory;
  bool _isRecurring = false;
  RecurrenceFrequency _recurrenceFrequency = RecurrenceFrequency.weekly;

  @override
  void dispose() {
    _addressController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_selectedDay == null) {
      _showSnackBar('Please select a date', AppColors.warning);
      return;
    }
    if (_selectedTimeSlot == null) {
      _showSnackBar('Please select a time slot', AppColors.warning);
      return;
    }
    if (_selectedCategory == null) {
      _showSnackBar('Please select a waste category', AppColors.warning);
      return;
    }
    if (_weightController.text.isEmpty ||
        double.tryParse(_weightController.text) == null) {
      _showSnackBar('Please enter a valid weight', AppColors.warning);
      return;
    }
    if (_addressController.text.trim().length < 10) {
      _showSnackBar('Please enter a complete address', AppColors.warning);
      return;
    }

    context.read<PickupBloc>().add(
          CreatePickupRequested(
            category: _selectedCategory!,
            estimatedWeight: double.parse(_weightController.text),
            address: _addressController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            scheduledDate: _selectedDay,
            timeSlot: _selectedTimeSlot,
            isRecurring: _isRecurring,
            recurrenceFrequency:
                _isRecurring ? _recurrenceFrequency : null,
            recurrenceDayOfWeek:
                _isRecurring ? _selectedDay!.weekday : null,
          ),
        );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schedule Pickup',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocListener<PickupBloc, PickupState>(
        listener: (context, state) {
          if (state is PickupCreated) {
            _showSnackBar(
              state.pickup.isRecurring
                  ? 'Recurring pickup scheduled! 🎉'
                  : 'Pickup scheduled for ${_selectedTimeSlot?.displayName}! 🎉',
              AppColors.success,
            );
            Navigator.pop(context);
          } else if (state is PickupError) {
            _showSnackBar(state.message, AppColors.error);
          }
        },
        child: BlocBuilder<PickupBloc, PickupState>(
          builder: (context, state) {
            final isLoading = state is CreatingPickup;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Calendar
                  _buildCalendar(),
                  const SizedBox(height: 24),

                  // Time Slots
                  _buildTimeSlots(),
                  const SizedBox(height: 24),

                  // Recurring Toggle
                  _buildRecurringSection(),
                  const SizedBox(height: 24),

                  // Waste Category
                  _buildCategorySection(isLoading),
                  const SizedBox(height: 24),

                  // Weight
                  _buildTextField(
                    controller: _weightController,
                    label: 'Estimated Weight (kg)',
                    hint: 'e.g. 5.0',
                    icon: Icons.scale_rounded,
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Address
                  _buildTextField(
                    controller: _addressController,
                    label: 'Pickup Address',
                    hint: 'Enter your full address',
                    icon: Icons.location_on_rounded,
                    maxLines: 2,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    hint: 'Any special instructions?',
                    icon: Icons.note_rounded,
                    maxLines: 2,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(isLoading),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final lastDay = now.add(const Duration(days: 14));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: TableCalendar(
        firstDay: now,
        lastDay: lastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarFormat: CalendarFormat.twoWeeks,
        availableCalendarFormats: const {CalendarFormat.twoWeeks: '2 weeks'},
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon:
              Icon(Icons.chevron_left, color: AppColors.textSecondary),
          rightChevronIcon:
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textPrimary,
          ),
          weekendTextStyle: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textSecondary,
          ),
          outsideTextStyle: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textMuted,
          ),
          todayTextStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreen,
          ),
          selectedTextStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
          weekendStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time Slot',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: PickupTimeSlot.values.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = slot),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      slot.displayName,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      slot.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white70
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecurringSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.repeat_rounded,
                  color: AppColors.primaryGreen, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recurring Pickup',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Auto-schedule on the same day & time',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isRecurring,
                onChanged: (val) => setState(() => _isRecurring = val),
                activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.5),
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primaryGreen;
                  }
                  return AppColors.textMuted;
                }),
              ),
            ],
          ),
          if (_isRecurring) ...[
            const SizedBox(height: 16),
            Row(
              children: RecurrenceFrequency.values.map((freq) {
                final isSelected = _recurrenceFrequency == freq;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _recurrenceFrequency = freq),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: freq == RecurrenceFrequency.weekly ? 8 : 0,
                          left: freq == RecurrenceFrequency.biweekly ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          freq.displayName,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waste Category',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: WasteCategory.values.map((cat) {
            final isSelected = _selectedCategory == cat;
            final color =
                Color(int.parse(cat.colorHex.replaceFirst('#', '0xFF')));
            return GestureDetector(
              onTap: isLoading
                  ? null
                  : () => setState(() => _selectedCategory = cat),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  cat.displayName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _handleSubmit,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isLoading
              ? AppColors.primaryGreen.withValues(alpha: 0.5)
              : AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isRecurring
                          ? 'Schedule Recurring Pickup'
                          : 'Schedule Pickup',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
