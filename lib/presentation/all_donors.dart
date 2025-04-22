import 'package:ems_project/Services/donor_api_service.dart';
import 'package:ems_project/presentation/widget/donor_responsive_header.dart';
import 'package:ems_project/presentation/widget/edit_donor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/donor_provider.dart';

class AllDonorsScreen extends ConsumerStatefulWidget {
  @override
  _DonorsScreenState createState() => _DonorsScreenState();
}

class _DonorsScreenState extends ConsumerState<AllDonorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(donorProvider.notifier).fetchDonors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final donorState = ref.watch(donorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Donors"),
        primary: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DonorResponsiveHeader(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDCE0E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFDCE0E5),
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              onChanged: (query) {
                ref.read(donorProvider.notifier).searchDonors(query);
              },
            ),
          ),
          Expanded(
            child:
            donorState.isLoading
                ? Center(child: CircularProgressIndicator())
                : donorState.error != null
                ? Center(child: Text("Error: ${donorState.error}"))
                : donorState.filteredDonors.isNotEmpty
                ? ListView.builder(
              itemCount: donorState.filteredDonors.length,
              itemBuilder: (context, index) {
                final donor = donorState.filteredDonors[index];

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _DonorsCard(
                      email: donor.email,
                      name: donor.name,
                      donorId: donor.id,
                    ),
                  ],
                );
              },
            )
                : Center(child: Text("No donor available.")),
          ),
        ],
      ),
    );
  }
}

class _DonorsCard extends ConsumerWidget {
  final String name;
  final String email;
  final String donorId;

  const _DonorsCard({
    Key? key,
    required this.name,
    required this.email,
    required this.donorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaSize = MediaQuery.of(context).size;
    return SizedBox(
      width: mediaSize.width * 0.9,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(mediaSize.height * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    child: Icon(Icons.more_vert, color: Colors.black54),
                    onTap:
                        () => _showDonorActionsDialog(
                      context,
                      donorId,
                      ref,
                      name,
                      email,
                    ),
                  ),
                ],
              ),
              SizedBox(height: mediaSize.height * 0.03),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Email: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: email,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: mediaSize.height * 0.03),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Organization: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: "Saad's Organization",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDonorActionsDialog(
    BuildContext context,
    String donorId,
    WidgetRef ref,
    String name,
    String email,
    ) {
  final DeleteDonorApiService apiService = DeleteDonorApiService();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Select Action for Donor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogOption(
              icon: Icons.edit,
              label: 'Edit',
              onTap: () {
                Navigator.of(context).pop();
                // Handle editing logic here
                showDialog(
                  context: context,
                  builder:
                      (context) => EditDonorDialog(
                    donorName: name,
                    donorEmail: email,
                    donorId: donorId,
                  ),
                ).then((result) {
                  if (result == true) {
                    // Refresh the student list or take other actions
                    ref.read(donorProvider.notifier).fetchDonors();
                  }
                });
              },
            ),
            _DialogOption(
              icon: Icons.delete,
              label: 'Delete',
              onTap: () async {
                final success = await apiService.deleteDonors(donorId);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Donor deleted successfully!")),
                  );
                  ref.read(donorProvider.notifier).fetchDonors();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete donor.")),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}


class _DialogOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DialogOption({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {



    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}









