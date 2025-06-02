import 'package:flutter/material.dart';

/// Data model for a single homework entry.
class HomeWorkData {
  final String tag;
  final String title;
  final String teacherName;
  final DateTime dueDate;
  final double progress;      // 0.0 – 1.0
  final String? thumbnailUrl; // e.g. network image URL
  final bool isSubmitted;     // Tracks whether homework is submitted

  HomeWorkData({
    required this.tag,
    required this.title,
    required this.teacherName,
    required this.dueDate,
    required this.progress,
    this.thumbnailUrl,
    required this.isSubmitted,
  });
}

/// The “Home Works” container + header + list of cards.
class HomeWorksWidget extends StatelessWidget {
  final List<HomeWorkData> items;
  final VoidCallback onFilterTap; // Callback to open subject filter

  const HomeWorksWidget({
    Key? key,
    required this.items,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
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
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Home Works',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: onFilterTap,
                  borderRadius: BorderRadius.circular(8),
                  hoverColor: Colors.blue.withOpacity(0.1),
                  child: Row(
                    children: const [
                      Icon(Icons.menu_book, size: 20),
                      SizedBox(width: 4),
                      Text('All Subjects', style: TextStyle(fontSize: 16)),
                      Icon(Icons.keyboard_arrow_down, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List or Empty State
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'No homework available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            Column(
              children: items.map((data) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _HomeWorkCard(data: data),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

/// Individual homework card widget.
class _HomeWorkCard extends StatelessWidget {
  final HomeWorkData data;

  const _HomeWorkCard({Key? key, required this.data}) : super(key: key);

  /// Determines the progress color based on the percentage value.
  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.orange; // 30% or less
    } else if (progress < 0.7) {
      return Colors.blue; // Between 30% and 70%
    } else {
      return Colors.green; // Above 70%
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = MediaQuery.of(context).size.width * 0.18;

    return Column(
      children: [
        Row(
          children: [
            // Thumbnail
            Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                image: data.thumbnailUrl != null
                    ? DecorationImage(
                  image: NetworkImage(data.thumbnailUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: data.thumbnailUrl == null
                  ? const Icon(Icons.image, size: 30, color: Colors.white30)
                  : null,
            ),
            const SizedBox(width: 12),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag
                  Row(
                    children: [
                      const Icon(Icons.label, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Tooltip(
                          message: data.tag,
                          child: Text(
                            data.tag,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Tooltip(
                    message: data.title,
                    child: Text(
                      data.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Teacher + due date
                  Text(
                    '${data.teacherName}   Due by: '
                        '${data.dueDate.day.toString().padLeft(2, '0')}/'
                        '${data.dueDate.month.toString().padLeft(2, '0')}/'
                        '${data.dueDate.year}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Progress or Submit Button
            SizedBox(
              width: 100, // Adjust width for a larger button
              height: 40, // Adjust height for a more prominent button
              child: data.isSubmitted
                  ? Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: data.progress,
                    strokeWidth: 4,
                    color: _getProgressColor(data.progress),
                    backgroundColor: Colors.grey[200],
                  ),
                  Text(
                    '${(data.progress ).round()}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              )
                  : ElevatedButton(
                onPressed: () {
                  // Define submission logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fixedSize: const Size(100, 40), // Updated size to match image
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Adjusted font size for clarity
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )

          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}