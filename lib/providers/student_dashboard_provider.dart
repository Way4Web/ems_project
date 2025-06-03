import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Domain/student_dashboard_models.dart';
import '../Services/student_dashboard_service.dart';

final classSessionRepositoryProvider = Provider((ref) => ClassSessionRepository());

final classSessionsProvider = FutureProvider<List<ClassSession>>((ref) async {
  final repository = ref.watch(classSessionRepositoryProvider);
  return repository.fetchClassSessions();
});

final todaysClassProvider = FutureProvider<ClassSession?>((ref) async {
  final allClasses = await ref.watch(classSessionsProvider.future);

  // Filter the list to find today's class
  final today = DateTime.now();
  final todaysClass = allClasses.where((classSession) {
    final startDate = DateTime.parse(classSession.startTime);
    return startDate.year == today.year &&
        startDate.month == today.month &&
        startDate.day == today.day;
  }).toList();

  // Return the first class for today, or null if none exist
  return todaysClass.isNotEmpty ? todaysClass.first : null;
});





