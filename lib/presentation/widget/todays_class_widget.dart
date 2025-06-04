import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ems_project/main.dart' show CommonClass;

// Secure storage instance
final secureStorage = FlutterSecureStorage();

// Class Session model
class ClassSession {
  final String id;
  final String title;
  final String startTime;
  final String endTime;
  final String? zoomLink;
  final String? imageUrl;

  ClassSession({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.zoomLink,
    this.imageUrl,
  });

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      zoomLink: json['zoomLink'],
      imageUrl: json['imageUrl'],
    );
  }
}

// API service
class ApiService {
  Future<List<ClassSession>> fetchClassSessions() async {
    final url = Uri.parse(
      '${CommonClass.urlCommon}api/student/classes',
    );
    final token = await secureStorage.read(key: "token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> classSessions = data['classSessions'];

      return classSessions.map((session) => ClassSession.fromJson(session)).toList();
    } else {
      throw Exception('Failed to load class sessions');
    }
  }
}

// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Provider for today's class sessions with auto-refresh capability
final todaysClassSessionsProvider = FutureProvider.autoDispose<List<ClassSession>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final allSessions = await apiService.fetchClassSessions();

  // Filter sessions for today's date only
  final today = DateTime.now();
  final todaySessions = allSessions.where((session) {
    final sessionDate = DateTime.parse(session.startTime);
    return sessionDate.year == today.year &&
        sessionDate.month == today.month &&
        sessionDate.day == today.day;
  }).toList();

  // Sort by start time
  todaySessions.sort((a, b) =>
      DateTime.parse(a.startTime).compareTo(DateTime.parse(b.startTime))
  );

  return todaySessions;
});

// Function to join zoom meeting (can be overridden when using the widget)
typedef JoinMeetingCallback = void Function(BuildContext context, String? zoomLink);

void defaultJoinZoomMeeting(BuildContext context, String? zoomLink) {
  if (zoomLink != null && zoomLink.isNotEmpty) {
    print('Joining meeting with link: $zoomLink');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joining class meeting...')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No meeting link available for this class'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// The actual widget you can include in your dashboard
class TodaysClassesWidget extends ConsumerStatefulWidget {
  final bool showHeader;
  final JoinMeetingCallback? onJoinMeeting;

  const TodaysClassesWidget({
    Key? key,
    this.showHeader = true,
    this.onJoinMeeting,
  }) : super(key: key);

  @override
  ConsumerState<TodaysClassesWidget> createState() => _TodaysClassesWidgetState();
}

class _TodaysClassesWidgetState extends ConsumerState<TodaysClassesWidget> {
  @override
  void initState() {
    super.initState();
    // Initial data fetch when widget is created
    ref.refresh(todaysClassSessionsProvider);
  }

  @override
  void didUpdateWidget(TodaysClassesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh data when widget is updated
    ref.refresh(todaysClassSessionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Get today's date for display
    final today = DateTime.now();
    final formattedDate = DateFormat('dd-MM-yyyy').format(today);

    // Watch the class sessions provider
    final classSessionsAsync = ref.watch(todaysClassSessionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional header with current date/time and user info
        if (widget.showHeader)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '2025-06-04 12:47:33', // Updated current date/time
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Way4Web', // Updated user login
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Today's Classes Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header row with title & date
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Class",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E4057),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Class Sessions List
              classSessionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $error',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(todaysClassSessionsProvider),
                          child: const Text('Retry'),
                        )
                      ],
                    ),
                  ),
                ),
                data: (classSessions) {
                  if (classSessions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text(
                          'No classes scheduled for today.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: classSessions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final session = classSessions[index];
                      final startTime = DateFormat('hh:mm a').format(
                        DateTime.parse(session.startTime),
                      );
                      final endTime = DateFormat('hh:mm a').format(
                        DateTime.parse(session.endTime),
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            // Class/Teacher image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: session.imageUrl != null
                                  ? Image.network(
                                session.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                              )
                                  : const Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Class title & time
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$startTime - $endTime',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Join button
                            TextButton(
                              onPressed: () => (widget.onJoinMeeting ?? defaultJoinZoomMeeting)(context, session.zoomLink),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                foregroundColor: Colors.blue[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Join',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}