// (Your imports remain the same)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

import 'home/todo_notes/todo_notes_bloc.dart';
import 'home/todo_notes/todo_notes_event.dart';
import 'home/todo_notes/todo_notes_state.dart';

// ADD THIS IMPORT ⬇️
import 'home/todo_notes/pdf_viewer_screen.dart';

class TodoNotesScreen extends StatefulWidget {
  const TodoNotesScreen({super.key});

  @override
  State<TodoNotesScreen> createState() => _TodoNotesScreenState();
}

class _TodoNotesScreenState extends State<TodoNotesScreen> {
  late final String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    final b = context.read<TodoNotesBloc>();
    b.add(LoadTodos(uid));
    b.add(LoadNotes(uid));
  }

  // ------------------- ADD TODO -------------------
  void addTodoDialog() {
    String x = "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add To-Do"),
        content: TextField(
          autofocus: true,
          onChanged: (v) => x = v,
          decoration: const InputDecoration(hintText: "To-Do"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (x.trim().isNotEmpty) {
                context.read<TodoNotesBloc>().add(AddTodo(uid, x.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ------------------- EDIT TODO -------------------
  void editTodoDialog(String id, String old) {
    String x = old;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit To-Do"),
        content: TextField(
          autofocus: true,
          controller: TextEditingController(text: x),
          onChanged: (v) => x = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (x.trim().isNotEmpty) {
                context.read<TodoNotesBloc>().add(EditTodo(uid, id, x.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ------------------- ADD TEXT NOTE -------------------
  void addNoteDialog() {
    String x = "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Note"),
        content: TextField(
          autofocus: true,
          onChanged: (v) => x = v,
          decoration: const InputDecoration(hintText: "Note"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (x.trim().isNotEmpty) {
                context.read<TodoNotesBloc>().add(AddNote(uid, x.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ------------------- EDIT NOTE -------------------
  void editNoteDialog(String id, String old) {
    String x = old;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Note"),
        content: TextField(
          autofocus: true,
          controller: TextEditingController(text: x),
          onChanged: (v) => x = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (x.trim().isNotEmpty) {
                context.read<TodoNotesBloc>().add(EditNote(uid, id, x.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ------------------- PICK IMAGE/PDF & UPLOAD -------------------
  void pickNoteAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final ext = result.files.single.extension!.toLowerCase();
    final fileType = ext == "pdf" ? "pdf" : "image";

    String noteText = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Note with Attachment"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Optional note text",
          ),
          onChanged: (v) => noteText = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TodoNotesBloc>().add(
                AddNoteWithAttachment(
                  uid,
                  noteText.trim().isEmpty ? null : noteText.trim(),
                  file,
                  fileType,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text("Upload"),
          )
        ],
      ),
    );
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("To-Do & Notes", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A2E1B),
        centerTitle: true,
      ),
      body: BlocBuilder<TodoNotesBloc, TodoNotesState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------- TODO LIST -------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("To-Do List",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: addTodoDialog,
                      ),
                    ],
                  ),

                  state.loading
                      ? const CircularProgressIndicator()
                      : Column(
                    children: state.todos.map((doc) {
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: doc['isDone'],
                            onChanged: (val) => context
                                .read<TodoNotesBloc>()
                                .add(ToggleTodo(uid, doc.id, val!)),
                          ),
                          title: Text(
                            doc['title'],
                            style: TextStyle(
                              decoration: doc['isDone']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    editTodoDialog(doc.id, doc['title']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => context
                                    .read<TodoNotesBloc>()
                                    .add(DeleteTodo(uid, doc.id)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // ------------------- NOTES SECTION -------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Notes",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.note_add, color: Colors.orange),
                            onPressed: addNoteDialog,
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file, color: Colors.green),
                            onPressed: pickNoteAttachment,
                          ),
                        ],
                      ),
                    ],
                  ),

                  state.loading
                      ? const CircularProgressIndicator()
                      : Column(
                    children: state.notes.map((doc) {
                      final data = doc.data() as Map<String, dynamic>? ?? {};

                      return Card(
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TEXT
                              if (data["text"] != null &&
                                  data["text"].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    data["text"],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),

                              // IMAGE PREVIEW
                              if (data.containsKey("fileUrl") &&
                                  data["fileType"] == "image")
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    data["fileUrl"],
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                              // PDF PREVIEW (CLICKABLE)
                              if (data.containsKey("fileUrl") &&
                                  data["fileType"] == "pdf")
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PDFViewerScreen(
                                          url: data["fileUrl"],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(Icons.picture_as_pdf,
                                          color: Colors.red, size: 28),
                                      SizedBox(width: 8),
                                      Text(
                                        "View PDF",
                                        style: TextStyle(
                                          fontSize: 16,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    editNoteDialog(doc.id, data["text"] ?? ""),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => context
                                    .read<TodoNotesBloc>()
                                    .add(DeleteNote(uid, doc.id)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
