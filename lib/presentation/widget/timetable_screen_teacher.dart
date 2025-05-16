import 'package:ems_project/Services/classsession_teacher_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ems_project/Domain/timetable_teacher_model.dart';

class TimetableWidget extends ConsumerStatefulWidget {
  final String userId;

  const TimetableWidget({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<TimetableWidget> createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends ConsumerState<TimetableWidget> {
  final PageController _pageController = PageController(initialPage: 0);
  DateTime _selectedDate = DateTime.now();
  int _currentPageIndex = 0;

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
      mainAxisSize: MainAxisSize.min, // This is important - don't use max
      children: [
        _buildHeader(context),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 20),
        timetableAsyncValue.when(
          data:
              (timetableEvents) =>
                  _buildTimetableCarousel(context, timetableEvents),
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => Center(
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
            const Text(
              'Class Timetable',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              });
              // You can add logic here to fetch timetable for the selected date
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
              });
              // You can add logic here to fetch timetable for the selected date
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {
        // Implement update functionality
        ref.invalidate(timetableProvider(widget.userId));
      },
      child: const Text(
        'Update Timetable',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {
        // Implement create functionality
      },
      child: const Text(
        'Create Timetable',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildTimetableCarousel(
    BuildContext context,
    List<TimetableEvent> events,
  ) {
    if (events.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No timetable events available')),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fixed height container for the PageView
        SizedBox(
          height: 250, // Fixed height instead of Expanded
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
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: _buildTimetableCard(events[index]),
                  );
                },
              ),
              if (events.length > 1) ...[
                Positioned(
                  left: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
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
                    backgroundColor: Colors.blue,
                    child: IconButton(
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
        // Page indicators
        if (events.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                events.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPageIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color:
                        _currentPageIndex == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimetableCard(TimetableEvent event) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              event.title ?? 'Untitled Event',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${dateFormat.format(event.startTime)} - ${dateFormat.format(event.endTime)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (event.description != null) Text(event.description!),
            if (event.title != null) ...[
              const SizedBox(height: 8),
              Text('Class: ${event.title}'),
            ],
          ],
        ),
      ),
    );
  }

  // Helper method to format time from your TimetableEvent model
  String _formatTime(DateTime? time) {
    if (time == null) return 'N/A';
    return DateFormat('HH:mm').format(time);
  }
}
