import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo_notes_event.dart';
import 'todo_notes_state.dart';
import 'package:studymate/services/cloudinary_service.dart';


class TodoNotesBloc extends Bloc<TodoNotesEvent, TodoNotesState> {
  TodoNotesBloc()
      : super(TodoNotesState(todos: [], notes: [], loading: false)) {
    on<LoadTodos>((event, emit) async {
      emit(state.copyWith(loading: true));
      final snap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.uid)
          .collection('todos')
          .get();
      emit(state.copyWith(todos: snap.docs, loading: false));
    });

    on<AddTodo>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.uid)
          .collection('todos')
          .add({"title": event.title, "isDone": false});
      add(LoadTodos(event.uid));
    });

    on<EditTodo>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.uid)
          .collection('todos')
          .doc(event.id)
          .update({"title": event.title});
      add(LoadTodos(event.uid));
    });

    on<DeleteTodo>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.uid)
          .collection('todos')
          .doc(event.id)
          .delete();
      add(LoadTodos(event.uid));
    });
    on<ToggleTodo>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.uid)
          .collection('todos')
          .doc(event.id)
          .update({"isDone": event.value});
      add(LoadTodos(event.uid));
    });
    on<LoadNotes>((event, emit) async {
      emit(state.copyWith(loading: true));
      final snap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.uid)
          .collection('notes')
          .get();
      emit(state.copyWith(notes: snap.docs, loading: false));
    });

    on<AddNote>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.uid)
          .collection('notes')
          .add({"text": event.text, "fileUrl": null, "fileType": null});
      add(LoadNotes(event.uid));
    });

    on<EditNote>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.uid)
          .collection('notes')
          .doc(event.id)
          .update({"text": event.text});
      add(LoadNotes(event.uid));
    });

    on<DeleteNote>((event, emit) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.uid)
          .collection('notes')
          .doc(event.id)
          .delete();
      add(LoadNotes(event.uid));
    });

    on<AddNoteWithAttachment>((event, emit) async {
      emit(state.copyWith(loading: true));

      // Upload to Cloudinary
      final url = await CloudService.uploadFile(
        event.file,
        event.fileType == "pdf" ? "raw" : "image",
      );

      if (url == null) {
        emit(state.copyWith(loading: false));
        return;
      }

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(event.uid)
          .collection("notes")
          .add({
        "text": event.text ?? "",
        "fileUrl": url,
        "fileType": event.fileType,
      });

      add(LoadNotes(event.uid));
    });
  }
}
