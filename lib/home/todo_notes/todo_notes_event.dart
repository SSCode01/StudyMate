import 'dart:io';

abstract class TodoNotesEvent {}

class LoadTodos extends TodoNotesEvent {
  final String uid;
  LoadTodos(this.uid);
}

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

class LoadNotes extends TodoNotesEvent {
  final String uid;
  LoadNotes(this.uid);
}

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
  final String? text;
  final File file;
  final String fileType; // image / pdf

  AddNoteWithAttachment(this.uid, this.text, this.file, this.fileType);
}
