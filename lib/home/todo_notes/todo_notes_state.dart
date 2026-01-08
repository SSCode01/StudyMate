import 'package:cloud_firestore/cloud_firestore.dart';

class TodoNotesState {
  final List<QueryDocumentSnapshot> todos;
  final List<QueryDocumentSnapshot> notes;
  final bool loading;

  TodoNotesState({
    required this.todos,
    required this.notes,
    required this.loading,
  });

  TodoNotesState copyWith({
    List<QueryDocumentSnapshot>? todos,
    List<QueryDocumentSnapshot>? notes,
    bool? loading,
  }) {
    return TodoNotesState(
      todos: todos ?? this.todos,
      notes: notes ?? this.notes,
      loading: loading ?? this.loading,
    );
  }
}
