import 'dart:convert';

class Progress {
  final String organizationId;
  final String organizationName;
  final List<ProgressItem> progress;

  Progress({
    required this.organizationId,
    required this.organizationName,
    required this.progress,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String,
      progress: (json['progress'] as List)
          .map((item) => ProgressItem.fromJson(item))
          .toList(),
    );
  }
}

class ProgressItem {
  final String id;
  final String module;
  final Metrics metrics;
  final RecordedBy recordedBy;
  final DateTime recordedAt;

  ProgressItem({
    required this.id,
    required this.module,
    required this.metrics,
    required this.recordedBy,
    required this.recordedAt,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    return ProgressItem(
      id: json['id'] as String,
      module: json['module'] as String,
      metrics: Metrics.fromJson(json['metrics']),
      recordedBy: RecordedBy.fromJson(json['recordedBy']),
      recordedAt: DateTime.parse(json['recordedAt']),
    );
  }
}

class Metrics {
  final int pagesRead;
  final int versesMemorized;
  final String namazLocation;

  Metrics({
    required this.pagesRead,
    required this.versesMemorized,
    required this.namazLocation,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      pagesRead: json['pagesRead'] as int,
      versesMemorized: json['versesMemorized'] as int,
      namazLocation: json['namazLocation'] as String,
    );
  }
}

class RecordedBy {
  final String id;
  final String name;
  final String email;

  RecordedBy({
    required this.id,
    required this.name,
    required this.email,
  });

  factory RecordedBy.fromJson(Map<String, dynamic> json) {
    return RecordedBy(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}