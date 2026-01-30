import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo_notes_event.dart';

class TodoNotesState {
  final List<QueryDocumentSnapshot> allTodos;
  final List<QueryDocumentSnapshot> allNotes;

  final List<QueryDocumentSnapshot> visibleTodos;
  final List<QueryDocumentSnapshot> visibleNotes;

  final String searchQuery;
  final SortType sortType;
  final TodoStatusFilter todoFilter;
  final NotesContentFilter notesFilter;

  final bool loading;

  TodoNotesState({
    required this.allTodos,
    required this.allNotes,
    required this.visibleTodos,
    required this.visibleNotes,
    required this.searchQuery,
    required this.sortType,
    required this.todoFilter,
    required this.notesFilter,
    required this.loading,
  });

  factory TodoNotesState.initial() {
    return TodoNotesState(
      allTodos: [],
      allNotes: [],
      visibleTodos: [],
      visibleNotes: [],
      searchQuery: "",
      sortType: SortType.newest,
      todoFilter: TodoStatusFilter.all,
      notesFilter: NotesContentFilter.all,
      loading: false,
    );
  }

  TodoNotesState copyWith({
    List<QueryDocumentSnapshot>? allTodos,
    List<QueryDocumentSnapshot>? allNotes,
    List<QueryDocumentSnapshot>? visibleTodos,
    List<QueryDocumentSnapshot>? visibleNotes,
    String? searchQuery,
    SortType? sortType,
    TodoStatusFilter? todoFilter,
    NotesContentFilter? notesFilter,
    bool? loading,
  }) {
    return TodoNotesState(
      allTodos: allTodos ?? this.allTodos,
      allNotes: allNotes ?? this.allNotes,
      visibleTodos: visibleTodos ?? this.visibleTodos,
      visibleNotes: visibleNotes ?? this.visibleNotes,
      searchQuery: searchQuery ?? this.searchQuery,
      sortType: sortType ?? this.sortType,
      todoFilter: todoFilter ?? this.todoFilter,
      notesFilter: notesFilter ?? this.notesFilter,
      loading: loading ?? this.loading,
    );
  }
}
