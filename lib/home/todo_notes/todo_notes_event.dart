import 'dart:io';

abstract class TodoNotesEvent {}


// ---------- LOAD ----------
class LoadTodos extends TodoNotesEvent {
  final String uid;
  LoadTodos(this.uid);
}

class LoadNotes extends TodoNotesEvent {
  final String uid;
  LoadNotes(this.uid);
}


// ---------- TODO CRUD ----------
class AddTodo extends TodoNotesEvent {
  final String uid;
  final String title;
  AddTodo(this.uid, this.title);
}

class EditTodo extends TodoNotesEvent {
  final String uid;
  final String id;
  final String title;
  EditTodo(this.uid, this.id, this.title);
}

class DeleteTodo extends TodoNotesEvent {
  final String uid;
  final String id;
  DeleteTodo(this.uid, this.id);
}

class ToggleTodo extends TodoNotesEvent {
  final String uid;
  final String id;
  final bool value;
  ToggleTodo(this.uid, this.id, this.value);
}


// ---------- NOTE CRUD ----------
class AddNote extends TodoNotesEvent {
  final String uid;
  final String text;
  AddNote(this.uid, this.text);
}

class EditNote extends TodoNotesEvent {
  final String uid;
  final String id;
  final String text;
  EditNote(this.uid, this.id, this.text);
}

class DeleteNote extends TodoNotesEvent {
  final String uid;
  final String id;
  DeleteNote(this.uid, this.id);
}

class AddNoteWithAttachment extends TodoNotesEvent {
  final String uid;
  final String text;
  final dynamic file; // ✅ File (mobile) OR Uint8List (web)
  final String fileType;

  AddNoteWithAttachment(this.uid, this.text, this.file, this.fileType);
}



// ---------- SEARCH ----------
class SearchChanged extends TodoNotesEvent {
  final String query;
  SearchChanged(this.query);
}


// ---------- FILTER ----------
enum TodoStatusFilter { all, completed, pending }
enum NotesContentFilter { all, withImage, textOnly }

class FilterChanged extends TodoNotesEvent {
  final TodoStatusFilter todoFilter;
  final NotesContentFilter notesFilter;

  FilterChanged({
    required this.todoFilter,
    required this.notesFilter,
  });
}


// ---------- SORT ----------
enum SortType { az, za, newest, oldest }

class SortChanged extends TodoNotesEvent {
  final SortType sortType;
  SortChanged(this.sortType);
}
