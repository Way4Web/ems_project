class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String teacherName;
  final bool submitted;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.teacherName,
    required this.submitted,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String).trim(),
      dueDate: DateTime.parse(json['dueDate'] as String),              // parse ISO date :contentReference[oaicite:2]{index=2}
      teacherName: (json['teacher']['name'] as String),
      submitted: json['submission'] != null,                            // null ⇒ not submitted :contentReference[oaicite:3]{index=3}
    );
  }
}
