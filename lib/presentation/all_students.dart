import 'package:ems_project/presentation/widget/responsive_header.dart';
import 'package:ems_project/presentation/widget/students_responsive_header.dart';
import 'package:ems_project/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllStudentScreen extends ConsumerStatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends ConsumerState<AllStudentScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studentProvider.notifier).fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Students"),
        primary: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body:
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StudentResponsiveHeader(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or email',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFDCE0E5),
                      ),
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
                      borderSide: BorderSide(
                        color: Color(
                          0xFFE0E0E0,
                        ), // Light grey color for enabled state
                      ),
                    ),

                  ),
                  onChanged: (query) {
                    ref.read(studentProvider.notifier).searchStudents(query);
                  },
                ),
              ),

              Expanded(
                child: studentState.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : studentState.error != null
                    ? Center(child: Text("Error: ${studentState.error}"))
                    : ListView.builder(
                      itemCount: studentState.filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = studentState.filteredStudents[index];
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            _StudentCard(
                              email: student.email,
                              name: student.name,
                              organization: studentState.organization,
                            ),
                          ],
                        );
                      },
                    ),
              ),
            ],
          ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     ref.read(studentProvider.notifier).fetchStudents();
      //   },
      //   child: Icon(Icons.refresh),
      // ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final String email;
  final String organization;

  const _StudentCard({
    Key? key,
    required this.name,
    required this.email,
    required this.organization,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
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
              SizedBox(height: mediaSize.height * 0.02),
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
                      text: organization,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: mediaSize.height * 0.02),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Role: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: "student",
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
