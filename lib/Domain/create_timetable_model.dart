// File: lib/Domain/timetable_event_data.dart

class TimetableEventData {
  String? id; // Added ID field

  String? title;
  String? startTime;
  String? endTime;
  String? type;
  String? description;

  TimetableEventData({
    this.id,
    this.title = '',
    this.startTime = '',
    this.endTime = '',
    this.type = 'Class',
    this.description = '',
  });

  // Add a factory constructor to create from DateTime if needed
  factory TimetableEventData.fromDateTime({
    String? title = '',
    DateTime? startTime,
    DateTime? endTime,
    String? type = 'Class',
    String? description = '',
  }) {
    return TimetableEventData(
      title: title,
      startTime: startTime != null ? _formatDateTime(startTime) : '',
      endTime: endTime != null ? _formatDateTime(endTime) : '',
      type: type,
      description: description,
    );
  }

  // Helper method for date formatting
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}