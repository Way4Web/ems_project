import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ems_project/main.dart' show CommonClass;
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final url = Uri.parse('${CommonClass.urlCommon}api/student/classes');
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

      return classSessions
          .map((session) => ClassSession.fromJson(session))
          .toList();
    } else {
      throw Exception('Failed to load class sessions');
    }
  }
}

// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Provider for selected date
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Provider for class sessions for the selected date
final classSessionsForDateProvider = FutureProvider.autoDispose.family<List<ClassSession>, DateTime>((ref, selectedDate) async {
  final apiService = ref.read(apiServiceProvider);
  final allSessions = await apiService.fetchClassSessions();

  // Filter sessions for the selected date
  final filteredSessions = allSessions.where((session) {
    final sessionDate = DateTime.parse(session.startTime);
    return sessionDate.year == selectedDate.year &&
        sessionDate.month == selectedDate.month &&
        sessionDate.day == selectedDate.day;
  }).toList();

  // Sort by start time
  filteredSessions.sort(
        (a, b) => DateTime.parse(a.startTime).compareTo(DateTime.parse(b.startTime)),
  );

  return filteredSessions;
});

// All class sessions provider (not filtered by date)
final allClassSessionsProvider = FutureProvider<List<ClassSession>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final allSessions = await apiService.fetchClassSessions();

  // Sort by date and time
  allSessions.sort((a, b) => DateTime.parse(a.startTime).compareTo(DateTime.parse(b.startTime)));

  return allSessions;
});

// Provider for events for calendar
final classSessionEventsProvider = Provider<Map<DateTime, List<ClassSession>>>((ref) {
  final allSessions = ref.watch(allClassSessionsProvider);

  final Map<DateTime, List<ClassSession>> eventMap = {};

  allSessions.whenData((sessions) {
    for (var session in sessions) {
      final sessionDate = DateTime.parse(session.startTime);
      final dateKey = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

      if (eventMap[dateKey] == null) {
        eventMap[dateKey] = [];
      }

      eventMap[dateKey]!.add(session);
    }
  });

  return eventMap;
});

// Function to join zoom meeting (can be overridden when using the widget)
typedef JoinMeetingCallback = void Function(BuildContext context, String? zoomLink);

// The actual widget you can include in your dashboard
class TodaysClassesWidget extends ConsumerStatefulWidget {
  final bool showHeader;
  final JoinMeetingCallback? onJoinMeeting;
  final bool showAllClasses; // New parameter to show all classes

  const TodaysClassesWidget({
    Key? key,
    this.showHeader = true,
    this.onJoinMeeting,
    this.showAllClasses = false, // Default to false to maintain backward compatibility
  }) : super(key: key);

  @override
  ConsumerState<TodaysClassesWidget> createState() => _TodaysClassesWidgetState();
}

class _TodaysClassesWidgetState extends ConsumerState<TodaysClassesWidget> {
  bool _showCalendar = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    // Get the selected date from the provider
    final selectedDate = ref.watch(selectedDateProvider);
    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

    // Watch the class sessions provider for the selected date
    final classSessionsAsync = ref.watch(classSessionsForDateProvider(selectedDate));

    // Watch events for the calendar
    final events = ref.watch(classSessionEventsProvider);

    // Check if the selected date is today
    final today = DateTime.now();
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    // Title text - show "Today's Class" if the selected date is today, otherwise show "Classes for [date]"
    final titleText = isToday ? "Today's Classes" : "Classes for ${DateFormat('MMM d').format(selectedDate)}";

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
                // Row(
                //   children: [
                //     Icon(Icons.access_time, size: 20, color: Colors.blue),
                //     SizedBox(width: 8),
                //     Text(
                //       '2025-06-05 05:38:43', // Updated current date/time
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ],
                // ),
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

        // Classes Card
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
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E4057),
                      ),
                    ),
                    // Date selector button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showCalendar = !_showCalendar;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar widget (visible when _showCalendar is true)
              if (_showCalendar)
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
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: selectedDate,
                          calendarFormat: _calendarFormat,
                          eventLoader: (day) {
                            final normalizedDay = DateTime(day.year, day.month, day.day);
                            return events[normalizedDay] ?? [];
                          },
                          selectedDayPredicate: (day) {
                            return isSameDay(selectedDate, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            ref.read(selectedDateProvider.notifier).state = selectedDay;
                            setState(() {
                              _showCalendar = false;
                            });
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              if (events.isNotEmpty) {
                                return Positioned(
                                  right: 1,
                                  bottom: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                    width: 8,
                                    height: 8,
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: true,
                            titleCentered: true,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                ref.read(selectedDateProvider.notifier).state = DateTime.now();
                              },
                              child: const Text('Today'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showCalendar = false;
                                });
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 32.0,
                    horizontal: 16.0,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $error',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(classSessionsForDateProvider(selectedDate)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (classSessions) {
                  if (classSessions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text(
                          'No classes scheduled for ${isToday ? 'today' : DateFormat('MMM d, yyyy').format(selectedDate)}.',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                      final startTime = DateFormat('hh:mm a').format(DateTime.parse(session.startTime));
                      final endTime = DateFormat('hh:mm a').format(DateTime.parse(session.endTime));

                      // Check if class is active now
                      final now = DateTime.now();
                      final sessionStart = DateTime.parse(session.startTime);
                      final sessionEnd = DateTime.parse(session.endTime);
                      final isActive = now.isAfter(sessionStart) && now.isBefore(sessionEnd);
                      final isPast = now.isAfter(sessionEnd);
                      final isFuture = now.isBefore(sessionStart);

                      // Status indicator color
                      Color statusColor;
                      String statusText;

                      // if (isActive) {
                      //   statusColor = Colors.green;
                      //   statusText = "Active";
                      // } else if (isPast) {
                      //   statusColor = Colors.grey;
                      //   statusText = "Completed";
                      // } else {
                      //   statusColor = Colors.orange;
                      //   statusText = "Upcoming";
                      // }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
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
                                  Row(
                                    children: [
                                      Text(
                                        session.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
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
                              onPressed: () {
                                // Always try to join when the button is clicked, but show warnings for non-active classes
                                if (isPast) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('This class has already ended, but attempting to join anyway'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else if (isFuture) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Joining this class'),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                }

                                // Always attempt to join the meeting
                                (widget.onJoinMeeting ?? defaultJoinZoomMeeting)(
                                  context,
                                  session.zoomLink,
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:  Colors.blue[50],
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

// Function to join zoom meeting by opening the URL
void defaultJoinZoomMeeting(BuildContext context, String? zoomLink) async {
  if (zoomLink != null && zoomLink.isNotEmpty) {
    try {
      final Uri url = Uri.parse(zoomLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch Zoom meeting'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error launching meeting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No meeting link available for this class'),
        backgroundColor: Colors.red,
      ),
    );
  }
}