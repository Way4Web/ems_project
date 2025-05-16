import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimetableEventData {
  String? title;
  String? startTime;
  String? endTime;
  String? type;
  String? description;

  TimetableEventData({
    this.title = '',
    this.startTime = '',
    this.endTime = '',
    this.type = 'Class',
    this.description = '',
  });
}

class CreateTimetableScreen extends StatefulWidget {
  const CreateTimetableScreen({Key? key}) : super(key: key);

  @override
  State<CreateTimetableScreen> createState() => _CreateTimetableScreenState();
}

class _CreateTimetableScreenState extends State<CreateTimetableScreen> {
  final List<TimetableEventData> _events = [TimetableEventData()];
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width > 600
            ? 600
            : MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Create Timetable',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventForm(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _events.removeAt(index);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Title',
            initialValue: _events[index].title,
            onChanged: (value) => _events[index].title = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDateTimeField(
            label: 'Start Time',
            initialValue: _events[index].startTime,
            onChanged: (value) => setState(() => _events[index].startTime = value),
            placeholder: 'dd-mm-yyyy --:--',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a start time';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDateTimeField(
            label: 'End Time',
            initialValue: _events[index].endTime,
            onChanged: (value) => setState(() => _events[index].endTime = value),
            placeholder: 'dd-mm-yyyy --:--',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an end time';
              }
              if (_events[index].startTime != null &&
                  _events[index].startTime!.isNotEmpty &&
                  _tryParseDateTime(value).isBefore(
                      _tryParseDateTime(_events[index].startTime!)
                  )) {
                return 'End time must be after start time';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Type',
            value: _events[index].type,
            items: const ['Class', 'Meeting', 'Exam', 'Other'],
            onChanged: (value) => setState(() => _events[index].type = value),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Description',
            initialValue: _events[index].description,
            onChanged: (value) => _events[index].description = value,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    required Function(String) onChanged,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    String? initialValue,
    required Function(String?) onChanged,
    required String placeholder,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: initialValue != null && initialValue.isNotEmpty
                  ? _tryParseDateTime(initialValue)
                  : DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: initialValue != null && initialValue.isNotEmpty
                    ? TimeOfDay.fromDateTime(_tryParseDateTime(initialValue))
                    : TimeOfDay.now(),
              );
              if (time != null) {
                final dateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
                onChanged(DateFormat('dd-MM-yyyy HH:mm').format(dateTime));
              }
            }
          },
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a type';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _events.add(TimetableEventData());
              });
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Event', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Return the list of events to be processed
                  Navigator.of(context).pop(_events);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Create Timetable',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to safely parse date times
  DateTime _tryParseDateTime(String value) {
    try {
      return DateFormat('dd-MM-yyyy HH:mm').parse(value);
    } catch (e) {
      return DateTime.now();
    }
  }
}