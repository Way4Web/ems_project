import 'dart:math';
import 'package:ems_project/Domain/create_timetable_model.dart';
import 'package:ems_project/Domain/timetable_teacher_model.dart';
import 'package:ems_project/Services/create_timetable_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class UpdateTimetableDialog extends ConsumerStatefulWidget {
  final String timetableId;
  final List<TimetableEvent> initialEvents;

  const UpdateTimetableDialog({
    Key? key,
    required this.timetableId,
    required this.initialEvents,
  }) : super(key: key);

  @override
  ConsumerState<UpdateTimetableDialog> createState() => _UpdateTimetableDialogState();
}

class _UpdateTimetableDialogState extends ConsumerState<UpdateTimetableDialog> {
  late List<TimetableEventData> _events;
  final _formKey = GlobalKey<FormState>();
  final List<String> _eventTypes = ['Class', 'Meeting', 'Exam', 'Study Group', 'Workshop'];
  bool _isLoading = false;

  // Updated date and user info
  final DateTime currentDateTime = DateTime.parse('2025-05-19 12:04:05');
  final String currentUser = 'Way4Web';

  // Date format for UI display
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    // Convert TimetableEvent to TimetableEventData for editing
    _events = widget.initialEvents.map((event) {
      final service = ref.read(timeTableServiceProvider);
      return service.convertEventToEventData(event);
    }).toList();

    // If there are no events, add an empty one
    if (_events.isEmpty) {
      _addNewEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,

      // Remove default insets
      insetPadding: EdgeInsets.zero,

      child: Container(
        width: min(screenWidth - 16, 600), // Width is screen width minus 16px, with max of 600
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display timetable ID (optional for debugging)
                        // Text('ID: ${widget.timetableId}',
                        //     style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 8),

                        for (int i = 0; i < _events.length; i++)
                          _buildEventForm(i),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Update Timetable',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventForm(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Event ${index + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_events.length > 1)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _events.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLabel('Title'),
          _buildTextField(
            hint: 'Enter event title',
            value: _events[index].title ?? '',
            onChanged: (value) => setState(() => _events[index].title = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Start Time'),
          _buildDateTimePicker(
            hint: 'dd-mm-yyyy --:--',
            dateString: _events[index].startTime,
            onChanged: (dateTimeStr) {
              setState(() => _events[index].startTime = dateTimeStr);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select start time';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('End Time'),
          _buildDateTimePicker(
            hint: 'dd-mm-yyyy --:--',
            dateString: _events[index].endTime,
            onChanged: (dateTimeStr) {
              setState(() => _events[index].endTime = dateTimeStr);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select end time';
              }

              // Compare dates if both are set
              if (_events[index].startTime != null &&
                  _events[index].startTime!.isNotEmpty &&
                  value.isNotEmpty) {
                try {
                  final startDate = dateFormat.parse(_events[index].startTime!);
                  final endDate = dateFormat.parse(value);
                  if (endDate.isBefore(startDate)) {
                    return 'End time must be after start time';
                  }
                } catch (e) {
                  // Parse error, but we'll let it pass as other validators will catch this
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Type'),
          _buildDropdown(
            value: _events[index].type ?? 'Class',
            items: _eventTypes,
            onChanged: (value) {
              if (value != null) {
                setState(() => _events[index].type = value);
              }
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Description'),
          _buildTextField(
            hint: 'Enter description',
            value: _events[index].description ?? '',
            onChanged: (value) => setState(() => _events[index].description = value),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildDateTimePicker({
    required String hint,
    String? dateString,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    // Convert string date to DateTime for the picker
    DateTime? dateTime;
    if (dateString != null && dateString.isNotEmpty) {
      try {
        dateTime = dateFormat.parse(dateString);
      } catch (e) {
        // Use updated default if parsing fails
        dateTime = currentDateTime;
      }
    } else {
      dateTime = currentDateTime;
    }

    return FormField<String>(
      initialValue: dateString,
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: dateTime!,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(dateTime!),
                  );
                  if (time != null) {
                    final selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );

                    // Convert the DateTime to a string for the model
                    final formattedDate = dateFormat.format(selectedDateTime);
                    onChanged(formattedDate);
                    state.didChange(formattedDate);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateString != null && dateString.isNotEmpty
                            ? dateString
                            : hint,
                        style: TextStyle(
                          color: dateString != null && dateString.isNotEmpty
                              ? Colors.black
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _addNewEvent,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Event', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              disabledBackgroundColor: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isLoading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
                  : const Text('Update Timetable'),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewEvent() {
    final newEvent = TimetableEventData(
      startTime: dateFormat.format(currentDateTime),
      endTime: dateFormat.format(currentDateTime.add(const Duration(hours: 1))),
      type: 'Class',
      description: 'Created by $currentUser',
    );
    setState(() {
      _events.add(newEvent);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref.read(
            updateTimetableProvider({
              'timetableId': widget.timetableId,
              'events': _events
            }).future
        );

        // Close dialog and return success
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (error) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating timetable: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}