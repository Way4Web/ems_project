import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String organization;
  final String status;
  final String quarterLabel;
  final String resultLabel;
  final VoidCallback onEdit;

  const ProfileCard({
    Key? key,
    this.name = 'Amy',
    this.organization = "Saad's Organization",
    this.status = 'Active',
    this.quarterLabel = '1st Quarterly',
    this.resultLabel = 'Pass',
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // get total width to size the image responsively
    final width = MediaQuery.of(context).size.width;
    final imageSize = (width * 0.18).clamp(50.0, 80.0);

    return Container(
      // margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Top row: avatar + name/org/status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // placeholder avatar
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '300×300',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // name / org / status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organization: $organization | Status: $status',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // dashed divider
          const DottedLine(
            dashColor: Colors.grey,
            lineThickness: 1,
          ),

          const SizedBox(height: 16),

          // Bottom row: quarter + pill + edit button
          Row(
            children: [
              // quarter + result pill
              Expanded(
                child: Row(
                  children: [
                    Text(
                      quarterLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            resultLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // edit button
              ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 14,color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
