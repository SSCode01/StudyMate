import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo_notes_event.dart';
import 'todo_notes_state.dart';
import 'package:studymate/services/cloudinary_service.dart';
class TodoNotesBloc extends Bloc<TodoNotesEvent, TodoNotesState> {
  TodoNotesBloc() : super(TodoNotesState.initial()) {

    // ================= PIPELINE =================
    void applyPipeline(Emitter<TodoNotesState> emit, TodoNotesState s) {
      var todos = [...s.allTodos];
      var notes = [...s.allNotes];

      if (s.searchQuery.isNotEmpty) {
        final q = s.searchQuery.toLowerCase();
        todos = todos.where((d) =>
            d['title'].toString().toLowerCase().contains(q)
        ).toList();

        notes = notes.where((d) =>
            (d['text'] ?? '').toString().toLowerCase().contains(q)
        ).toList();
      }

      if (s.todoFilter == TodoStatusFilter.completed) {
        todos = todos.where((d) => d['isDone'] == true).toList();
      } else if (s.todoFilter == TodoStatusFilter.pending) {
        todos = todos.where((d) => d['isDone'] == false).toList();
      }

      if (s.notesFilter == NotesContentFilter.withImage) {
        notes = notes.where((d) => d['fileType'] != null).toList();
      } else if (s.notesFilter == NotesContentFilter.textOnly) {
        notes = notes.where((d) => d['fileType'] == null).toList();
      }

      int sort(QueryDocumentSnapshot a, QueryDocumentSnapshot b) {
        if (s.sortType == SortType.az) {
          return (a['title'] ?? a['text'] ?? '')
              .compareTo(b['title'] ?? b['text'] ?? '');
        } else if (s.sortType == SortType.za) {
          return (b['title'] ?? b['text'] ?? '')
              .compareTo(a['title'] ?? a['text'] ?? '');
        } else if (s.sortType == SortType.newest) {
          return b['createdAt'].compareTo(a['createdAt']);
        } else {
          return a['createdAt'].compareTo(b['createdAt']);
        }
      }

      todos.sort(sort);
      notes.sort(sort);

      emit(s.copyWith(
        visibleTodos: todos,
        visibleNotes: notes,
      ));
    }

    // ================= LOAD =================
    on<LoadTodos>((e, emit) async {
      emit(state.copyWith(loading: true));
      final snap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(e.uid)
          .collection('todos')
          .get();

      applyPipeline(
        emit,
        state.copyWith(allTodos: snap.docs, loading: false),
      );
    });

    on<LoadNotes>((e, emit) async {
      emit(state.copyWith(loading: true));
      final snap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(e.uid)
          .collection('notes')
          .get();

      applyPipeline(
        emit,
        state.copyWith(allNotes: snap.docs, loading: false),
      );
    });

    // ================= TODO CRUD =================
    on<AddTodo>((e, _) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(e.uid)
          .collection('todos')
          .add({
        'title': e.title,
        'isDone': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      add(LoadTodos(e.uid));
    });

    on<EditTodo>((e, _) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(e.uid)
          .collection('todos')
          .doc(e.id)
          .update({'title': e.title});
      add(LoadTodos(e.uid));
    });

    on<DeleteTodo>((e, _) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(e.uid)
          .collection('todos')
          .doc(e.id)
          .delete();
      add(LoadTodos(e.uid));
    });

    on<ToggleTodo>((e, _) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(e.uid)
          .collection('todos')
          .doc(e.id)
          .update({'isDone': e.value});
      add(LoadTodos(e.uid));
    });

    // ================= NOTES CRUD =================
    on<AddNote>((e, _) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(e.uid)
          .collection('notes')
          .add({
        'text': e.text,
        'fileUrl': null,
        'fileType': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      add(LoadNotes(e.uid));
    });

    on<EditNote>((e, _) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(e.uid)
          .collection('notes')
          .doc(e.id)
          .update({'text': e.text});
      add(LoadNotes(e.uid));
    });

    on<DeleteNote>((e, _) async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(e.uid)
          .collection('notes')
          .doc(e.id)
          .delete();
      add(LoadNotes(e.uid));
    });

    // ================= ATTACHMENT (FIXED) =================
    on<AddNoteWithAttachment>((e, emit) async {
      emit(state.copyWith(loading: true));


      final url = await CloudService.upload(e.file, e.fileType);


      if (url == null) {
        emit(state.copyWith(loading: false));
        return;
      }

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(e.uid)
          .collection('notes')
          .add({
        'text': e.text.isNotEmpty
            ? e.text
            : (e.fileType == 'pdf'
            ? 'PDF Attachment'
            : 'Image Attachment'),
        'fileUrl': url,
        'fileType': e.fileType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(state.copyWith(loading: false));
      add(LoadNotes(e.uid));
    });

    // ================= SEARCH / FILTER / SORT =================
    on<SearchChanged>((e, emit) {
      applyPipeline(
        emit,
        state.copyWith(searchQuery: e.query),
      );
    });

    on<SortChanged>((e, emit) {
      applyPipeline(
        emit,
        state.copyWith(sortType: e.sortType),
      );
    });

    on<FilterChanged>((e, emit) {
      applyPipeline(
        emit,
        state.copyWith(
          todoFilter: e.todoFilter,
          notesFilter: e.notesFilter,
        ),
      );
    });
  }
}
