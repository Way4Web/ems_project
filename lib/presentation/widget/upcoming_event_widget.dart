import 'package:ems_project/Services/get_class_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Current date/time and user constants
final DateTime currentDateTime = DateTime.parse('2025-05-29 10:00:24');
const String currentUserLogin = 'Way4WebPerforming';

class UpcomingEventsWidget extends ConsumerWidget {
  final Function() onRefresh;

  const UpcomingEventsWidget({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the getClassSessionsProvider to fetch events
    final eventsAsyncValue = ref.watch(classSessionNotifierProvider);
    // Create a scroll controller for the Scrollbar
    final ScrollController scrollController = ScrollController();

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.all(0.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                  tooltip: 'Refresh events',
                ),
              ],
            ),
            const SizedBox(height: 12),
            eventsAsyncValue.when(
              // Loading State
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),

              // Error State
              error:
                  (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Error: $error',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: onRefresh,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),

              // Data State
              data: (data) {
                final allEvents = data['classSessions'] ?? [];

                // Filter for only future events (happening today or in the future)
                final upcomingEvents =
                    allEvents.where((event) {
                      try {
                        // Parse start time
                        final startTime = DateTime.parse(
                          event['startTime'] ?? '',
                        );

                        // Check if today's date or future date
                        final isSameDay =
                            startTime.year == currentDateTime.year &&
                            startTime.month == currentDateTime.month &&
                            startTime.day == currentDateTime.day;

                        final isFutureDay = startTime.isAfter(currentDateTime);

                        return isSameDay || isFutureDay;
                      } catch (e) {
                        print('Error parsing date: $e');
                        return false;
                      }
                    }).toList();

                return upcomingEvents.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: Center(
                        child: Text(
                          'No upcoming events found.',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                    : SizedBox(
                      height:
                          MediaQuery.of(context).size.height *
                          0.21, // Height to show 2 cards
                      child: Scrollbar(
                        controller: scrollController, // Add the controller
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: scrollController,
                          // Add controller here too
                          physics: const BouncingScrollPhysics(),
                          // Smooth scrolling
                          itemCount: upcomingEvents.length,
                          itemBuilder: (context, index) {
                            final event = upcomingEvents[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                // Card height for 2 visible cards
                                child: EventCard(
                                  event: event,
                                  onAttendanceMarked: onRefresh,
                                  currentUserLogin: currentUserLogin,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
              },
            ),
            // Footer with timestamp
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "",
                  // 'Last updated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDateTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends ConsumerWidget {
  final Map<String, dynamic> event;
  final Function() onAttendanceMarked;
  final String currentUserLogin;

  const EventCard({
    super.key,
    required this.event,
    required this.onAttendanceMarked,
    required this.currentUserLogin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Format the date and time
    final date = DateFormat(
      'EEEE, MMM d, yyyy',
    ).format(DateTime.parse(event['startTime']));
    final startTime = DateFormat(
      'h:mm a',
    ).format(DateTime.parse(event['startTime']));
    final endTime = DateFormat(
      'h:mm a',
    ).format(DateTime.parse(event['endTime']));

    // Check if attendance has already been marked for this event
    final bool attendanceMarked =
        event['attendanceMarked'] == true ||
        event['attendanceStatus'] == 'marked' ||
        (event['attendance'] != null &&
            (event['attendance'] is List &&
                (event['attendance'] as List).isNotEmpty));

    // Safely get the first student ID or use a fallback
    String firstStudentId = '';
    if (event['students'] != null) {
      if (event['students'] is List && (event['students'] as List).isNotEmpty) {
        firstStudentId = event['students'][0].toString();
      }
    }

    return Card(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Left colored bar (for visual indication)
            Container(
              width: 5,
              height: double.infinity,
              color:
                  attendanceMarked
                      ? Colors.green
                      : Colors.red, // Green if marked, Red if not
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    event['title'] ?? 'Untitled Event',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Event Date
                  Text(
                    'Date: $date',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),

                  // Event Time Range
                  Text(
                    'Time: $startTime - $endTime',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),

                  // Attendance Button
                  attendanceMarked
                      ? Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Attendance Marked',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                      : ElevatedButton(
                        onPressed:
                            firstStudentId.isEmpty
                                ? null
                                : () async {
                                  // Show loading dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const AlertDialog(
                                        content: Row(
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(width: 20),
                                            Text("Marking attendance..."),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  try {
                                    // Implement the mark attendance logic
                                    await AttendanceService.markAttendance(
                                      event['id'], // sessionId
                                      event['students'][0], // studentId
                                      true, // attended
                                    );

                                    // Close loading dialog
                                    if (context.mounted)
                                      Navigator.of(context).pop();

                                    // Show success message
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Attendance marked successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }

                                    // Refresh the data
                                    onAttendanceMarked();
                                  } catch (e) {
                                    // Close loading dialog
                                    if (context.mounted)
                                      Navigator.of(context).pop();

                                    // Show error message
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error marking attendance: $e',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                        child: const Text(
                          'Mark Attendance',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mock attendance service - replace with your actual implementation
