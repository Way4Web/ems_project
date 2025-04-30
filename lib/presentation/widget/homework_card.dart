import 'package:flutter/material.dart';

/// Data model for a single homework entry.
class HomeWorkData {
  final String tag;
  final String title;
  final String teacherName;
  final DateTime dueDate;
  final double progress;      // 0.0 – 1.0
  final String? thumbnailUrl; // e.g. network image URL

  HomeWorkData({
    required this.tag,
    required this.title,
    required this.teacherName,
    required this.dueDate,
    this.progress = 0.0,
    this.thumbnailUrl,
  });
}

/// The “Home Works” container + header + list of cards.
class HomeWorksWidget extends StatelessWidget {
  final List<HomeWorkData> items;
  final VoidCallback onFilterTap; // to open subject filter

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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
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
                  child: Row(
                    children: const [
                      Icon(Icons.menu_book, size: 20),
                      SizedBox(width: 4),
                      Text('All Subject', style: TextStyle(fontSize: 16)),
                      Icon(Icons.keyboard_arrow_down, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          Column(
            children: items.map((data) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _HomeWorkCard(data: data),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

/// Individual homework card.
class _HomeWorkCard extends StatelessWidget {
  final HomeWorkData data;
  const _HomeWorkCard({ Key? key, required this.data }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thumbSize = MediaQuery.of(context).size.width * 0.18;
    return Row(
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
                fit: BoxFit.cover)
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
                ],
              ),
              const SizedBox(height: 4),
              // Title
              Text(
                data.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              // Teacher + due date
              Text(
                '${data.teacherName}   Due by: '
                    '${data.dueDate.day.toString().padLeft(2,'0')}/'
                    '${data.dueDate.month.toString().padLeft(2,'0')}/'
                    '${data.dueDate.year}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Progress circle
        SizedBox(
          width: thumbSize,
          height: thumbSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: data.progress,
                strokeWidth: 4,
                color: Colors.grey[200],
                // backgroundColor: Colors.green,
                backgroundColor: Colors.grey[200],
              ),
              Text(
                '${(data.progress * 100).round()}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


