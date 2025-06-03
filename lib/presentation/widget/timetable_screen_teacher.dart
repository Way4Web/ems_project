import 'package:ems_project/Domain/create_timetable_model.dart';
import 'package:ems_project/Services/classsession_teacher_service.dart';
import 'package:ems_project/Services/create_timetable_service.dart'
    show createTimetableProvider, updateTimetableProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ems_project/Domain/timetable_teacher_model.dart';

import 'create_timetable_teacher_dialog.dart';
import 'update_timetable_dialog.dart';

class TimetableWidget extends ConsumerStatefulWidget {
  final String userId;
  final DateTime? selectedDate;

  const TimetableWidget({
    Key? key,
    required this.userId,
    this.selectedDate,
  }) : super(key: key);

  @override
  ConsumerState<TimetableWidget> createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends ConsumerState<TimetableWidget> {
  final PageController _pageController = PageController(initialPage: 0);
  late DateTime _selectedDate;
  int _currentPageIndex = 0;

  // Default timetable ID if needed
  final String defaultTimetableId = '682b0e9b9d783e6f901e6f85';

  // Current date/time and user
  final DateTime currentDateTime = DateTime.parse('2025-06-03 11:14:42');
  final String currentUser = 'Way4Web';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(TimetableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local date when parent widget passes a new date
    if (widget.selectedDate != null && widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        _selectedDate = widget.selectedDate!;
        _resetPageController();
      });
    }
  }

  void _resetPageController() {
    _currentPageIndex = 0;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timetableAsyncValue = ref.watch(timetableProvider(widget.userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 10),
        timetableAsyncValue.when(
          data: (timetableEvents) {
            // Print debug info
            print('Total events: ${timetableEvents.length}');
            print('Selected date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}');

            // Filter events that are active on the selected date
            // An event is "active" if the selected date falls between the event's start and end date (inclusive)
            final activeEvents = timetableEvents.where((event) {
              final selectedDateOnly = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
              );

              final eventStartDate = DateTime(
                event.startTime.year,
                event.startTime.month,
                event.startTime.day,
              );

              final eventEndDate = DateTime(
                event.endTime.year,
                event.endTime.month,
                event.endTime.day,
              );

              // Event is active if selected date falls between event's start and end dates (inclusive)
              return (selectedDateOnly.isAtSameMomentAs(eventStartDate) ||
                  selectedDateOnly.isAfter(eventStartDate)) &&
                  (selectedDateOnly.isAtSameMomentAs(eventEndDate) ||
                      selectedDateOnly.isBefore(eventEndDate));
            }).toList();

            print('Active events: ${activeEvents.length}');

            return _buildSimplifiedTimetableCarousel(context, activeEvents);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error loading timetable: ${error.toString()}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return isSmallScreen
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Class Timetable',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDatePicker(context),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildUpdateButton()),
            const SizedBox(width: 8),
            Expanded(child: _buildCreateButton()),
          ],
        ),
      ],
    )
        : Row(
      children: [
        const Text(
          'Class Timetable',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        _buildDatePicker(context),
        const Spacer(),
        _buildUpdateButton(),
        const SizedBox(width: 8),
        _buildCreateButton(),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                _resetPageController();
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(dateFormat.format(_selectedDate)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
                _resetPageController();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.062,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () => _showUpdateAllEventsDialog(),
        child: const Text(
          'Update Timetable',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showUpdateAllEventsDialog() {
    final timetableAsyncValue = ref.watch(timetableProvider(widget.userId));

    timetableAsyncValue.when(
      data: (events) {
        if (events.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No events to update')));
          return;
        }

        // Use the first event's ID as the timetable ID (or default)
        final timetableId =
        events.isNotEmpty && events[0].id != null
            ? events[0].id!
            : defaultTimetableId;

        showDialog(
          context: context,
          builder: (context) => UpdateTimetableDialog(
            timetableId: timetableId,
            initialEvents: events, // Pass all events to the dialog
          ),
        ).then((result) {
          if (result == true) {
            // Refresh the timetable data
            ref.invalidate(timetableProvider(widget.userId));

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Timetable updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      },
      loading: () => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loading events...'))),
      error: (_, __) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load events to update'),
          backgroundColor: Colors.red,
        ),
      ),
    );
  }

  void _handleUpdateEvent(TimetableEvent event) {
    final timetableId = event.id ?? defaultTimetableId;

    showDialog(
      context: context,
      builder: (context) => UpdateTimetableDialog(
        timetableId: timetableId,
        initialEvents: [event], // Pass only this event to the dialog
      ),
    ).then((result) {
      if (result == true) {
        // Refresh the timetable data
        ref.invalidate(timetableProvider(widget.userId));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  Widget _buildCreateButton() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.062,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => CreateTimetableDialog(
              initialDate: _selectedDate, // Pass the selected date to create dialog
            ),
          ).then((result) {
            if (result != null && result is List<TimetableEventData>) {
              _handleCreatedEvents(result);
            }
          });
        },
        child: const Text(
          'Create Timetable',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _handleCreatedEvents(List<TimetableEventData> events) async {
    // Show loading indicator
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Creating events...')));

    try {
      // Use the createTimetable provider
      await ref.read(
        createTimetableProvider({
          'userId': widget.userId,
          'events': events,
          'context': context
        }).future,
      );

      // If we get here, it was successful
      // Refresh the timetable data
      ref.invalidate(timetableProvider(widget.userId));
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // New simplified carousel that matches the screenshot design
  Widget _buildSimplifiedTimetableCarousel(BuildContext context, List<TimetableEvent> events) {
    if (events.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No timetable events available for ${DateFormat("dd MMM yyyy").format(_selectedDate)}',
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CreateTimetableDialog(
                      initialDate: _selectedDate,
                    ),
                  ).then((result) {
                    if (result != null && result is List<TimetableEventData>) {
                      _handleCreatedEvents(result);
                    }
                  });
                },
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed height container for the PageView
          SizedBox(
            height: 180, // Adjusted height to match screenshot
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: events.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.18),
                      child: _buildSimplifiedTimetableCard(events[index], index),
                    );
                  },
                ),
                if (events.length > 1) ...[
                  Positioned(
                    left: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedTimetableCard(TimetableEvent event, int index) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM yyyy');

    // Use index to alternate between creators as shown in the screenshot
    String creatorName = index % 2 == 0 ? 'Way4' : 'Way4Webjwje';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time badge at the top
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Event title
          Text(
            event.title ?? 'Untitled Event',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Date range
          Text(
            '${dateFormat.format(event.startTime)} - ${dateFormat.format(event.endTime)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),

        ],
      ),
    );
  }

  // Helper method to format time from your TimetableEvent model
  String _formatTime(DateTime? time) {
    if (time == null) return 'N/A';
    return DateFormat('HH:mm').format(time);
  }
}