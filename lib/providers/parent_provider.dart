import 'package:ems_project/Domain/parent_model.dart';
import 'package:ems_project/Services/parent_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final parentProvider = StateNotifierProvider<ParentNotifier, ParentState>((ref) {
  return ParentNotifier(ParentApiService());
});

class ParentState {
  final List<Parent> parents;
  final List<Parent>? filteredParents;
  final bool isLoading;
  final String? error;

  ParentState({
    required this.parents,
    required this.filteredParents,
    required this.isLoading,
    this.error,
  });

  ParentState copyWith({
    List<Parent>? parents,
    List<Parent>? filteredParents,
    bool? isLoading,
    String? error,
  }) {
    return ParentState(
      parents: parents ?? this.parents,
      filteredParents: filteredParents ?? this.filteredParents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ParentNotifier extends StateNotifier<ParentState> {
  final ParentApiService apiService;

  ParentNotifier(this.apiService)
      : super(ParentState(
    parents: [],
    filteredParents: [],
    isLoading: false,
  ));

  Future<void> fetchParents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final parents = await apiService.fetchParents();
      state = state.copyWith(
        parents: parents?.parents,
        filteredParents: parents?.parents,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void searchParents(String query) {
    final filtered = state.parents.where((parent) {
      final nameLower = parent.name.toLowerCase();
      final emailLower = parent.email.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) || emailLower.contains(searchLower);
    }).toList();

    state = state.copyWith(filteredParents: filtered);
  }

  void deleteParentLocally(String parentId) {
    final updatedParents = state.parents.where((p) => p.id != parentId).toList();
    state = state.copyWith(
      parents: updatedParents,
      filteredParents: updatedParents,
    );
  }

  Future<void> deleteParent(String parentId) async {
    try {
      // Perform API call to delete parent
      deleteParentLocally(parentId); // Optimistic update (local deletion)
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}