import 'package:ems_project/Services/get_class_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class UpcomingEventsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the getClassSessionsProvider to fetch events
    final eventsAsyncValue = ref.watch(
      GetClassSessionService.getClassSessionsProvider,
    );

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
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            eventsAsyncValue.when(
              // Loading State
              loading: () => const Center(child: CircularProgressIndicator()),

              // Error State
              error:
                  (error, stack) => Center(
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

              // Data State
              data: (data) {
                final events = data['classSessions'] ?? [];
                return events.isEmpty
                    ? const Center(child: Text('No upcoming events found.'))
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return EventCard(event: event);
                      },
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
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

    return Card(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Left colored bar (for visual indication)
            Container(
              width: 5,
              height: MediaQuery.of(context).size.height * 0.16,
              color: Colors.red, // Customize color per event
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

                  // Zoom Link (or a generic message if none available)
                  ElevatedButton(
                    onPressed: () {
                      // Implement the mark attendance logic
                    },
                    child: const Text(
                      'Mark Attendance',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
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
            // Action Button (Mark Attendance)
          ],
        ),
      ),
    );
  }
}
