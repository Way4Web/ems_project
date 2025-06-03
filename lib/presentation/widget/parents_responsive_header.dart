import 'package:ems_project/providers/organizations_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_parent.dart';
import 'add_students.dart';

class ParentResponsiveHeader extends ConsumerWidget {
  const ParentResponsiveHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final organizationsState = ref.watch(organizationsProvider);
    if (organizationsState.isLoading &&
        organizationsState.organizations == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(organizationsProvider.notifier).fetchOrganizations();
      });
    }

    // Always use a Row layout
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Parents',
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddParents(),
              ),
            ).then((_) {
              ref
                  .read(organizationsProvider.notifier)
                  .fetchOrganizations();
            });

          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_box_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text('Add Parent', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
