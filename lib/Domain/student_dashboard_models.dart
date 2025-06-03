class ClassSession {
  final String id;
  final String title;
  final String startTime;
  final String endTime;
  final String zoomLink;

  ClassSession({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.zoomLink,
  });

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      id: json['id'],
      title: json['title'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      zoomLink: json['zoomLink'],
    );
  }
}