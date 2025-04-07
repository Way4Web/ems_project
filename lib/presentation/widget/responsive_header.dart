import 'package:flutter/material.dart';

class ResponsiveHeader extends StatelessWidget {
  const ResponsiveHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Always use a Row layout
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Manage Organizations',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff3366ff),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),

            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () {
            // TODO: Add your onPressed logic
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_box_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text('Add Organization', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
