import 'package:ems_project/Domain/create_timetable_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateTimetableDialog extends StatefulWidget {
  const CreateTimetableDialog({Key? key, required DateTime initialDate}) : super(key: key);

  @override
  _CreateTimetableDialogState createState() => _CreateTimetableDialogState();
}

class _CreateTimetableDialogState extends State<CreateTimetableDialog> {
  // Use the existing model
  final List<TimetableEventData> _events = [TimetableEventData()];
  final _formKey = GlobalKey<FormState>();
  final List<String> _eventTypes = ['Class', 'Meeting', 'Exam', 'Study Group', 'Workshop'];

  // Format for dates and default date
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm');
  final DateTime defaultDateTime = DateTime.parse('2025-05-19 09:27:08Z');
  static const String currentUser = 'Way4Web';

  @override
  void initState() {
    super.initState();
    // Initialize events with default dates
    if (_events.isNotEmpty) {
      _events[0].startTime = dateFormat.format(defaultDateTime);
      _events[0].endTime = dateFormat.format(defaultDateTime.add(const Duration(hours: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width > 600
              ? 600
              : MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
            'Create Timetable',
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
        // Use default if parsing fails
        dateTime = defaultDateTime;
      }
    } else {
      dateTime = defaultDateTime;
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
                  initialDate: dateTime ?? defaultDateTime,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: dateTime != null
                        ? TimeOfDay.fromDateTime(dateTime)
                        : TimeOfDay.fromDateTime(defaultDateTime),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _addNewEvent,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Event', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Create Timetable'),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewEvent() {
    final newEvent = TimetableEventData(
      startTime: dateFormat.format(defaultDateTime),
      endTime: dateFormat.format(defaultDateTime.add(const Duration(hours: 1))),
      type: 'Class',
    );
    setState(() {
      _events.add(newEvent);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Return the list of events to the caller
      Navigator.of(context).pop(_events);
    }
  }
}