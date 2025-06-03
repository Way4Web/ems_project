import 'package:flutter/material.dart';


class ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 5,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jade',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  icon: Icon(Icons.more_vert),
                  underline: SizedBox(),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'View Student',
                      child: Text('View Student'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Edit',
                      child: Text('Edit'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Promote Student',
                      child: Text('Promote Student'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      print(value);
                    }
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Add Fees'),
            ),
          ],
        ),
      ),
    );
  }
}
