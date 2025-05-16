class TimetableEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String description;

  TimetableEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
  });

  factory TimetableEvent.fromJson(Map<String, dynamic> json) {
    return TimetableEvent(
      id: json['_id'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      description: json['description'],
    );
  }
}
