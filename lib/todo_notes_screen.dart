import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/foundation.dart';
import 'home/todo_notes/todo_notes_bloc.dart';
import 'home/todo_notes/todo_notes_event.dart';
import 'home/todo_notes/todo_notes_state.dart';
import 'home/todo_notes/pdf_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class TodoNotesScreen extends StatefulWidget {
  const TodoNotesScreen({super.key});

  @override
  State<TodoNotesScreen> createState() => _TodoNotesScreenState();
}

class _TodoNotesScreenState extends State<TodoNotesScreen> {
  late final String uid;
  TodoStatusFilter todoFilter = TodoStatusFilter.all;
  NotesContentFilter notesFilter = NotesContentFilter.all;


  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    final b = context.read<TodoNotesBloc>();
    b.add(LoadTodos(uid));
    b.add(LoadNotes(uid));
  }

  void applyFilter() {
    context.read<TodoNotesBloc>().add(
      FilterChanged(todoFilter: todoFilter, notesFilter: notesFilter),
    );
  }

  void addTodo() {
    String x = "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add To-Do"),
        content: TextField(onChanged: (v) => x = v),
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
          )
        ],
      ),
    );
  }

  void addNote() {
    String x = "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Note"),
        content: TextField(onChanged: (v) => x = v),
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
          )
        ],
      ),
    );
  }

  void attachNote() async {
    String title = "";

    // 🔤 Ask for note name first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Note title"),
        content: TextField(
          autofocus: true,
          onChanged: (v) => title = v,
          decoration: const InputDecoration(
            hintText: "Enter note name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Continue"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 📂 Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: kIsWeb,
    );

    if (result == null) return;

    final ext = result.files.single.extension!.toLowerCase();
    final type = ext == 'pdf' ? 'pdf' : 'image';

    if (kIsWeb) {
      context.read<TodoNotesBloc>().add(
        AddNoteWithAttachment(uid, title, result.files.single.bytes!, type),
      );
    } else {
      context.read<TodoNotesBloc>().add(
        AddNoteWithAttachment(uid, title, File(result.files.single.path!), type),
      );
    }
  }



  void editDialog(String initial, Function(String) onSave) {
    String txt = initial;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit"),
        content: TextField(
          controller: TextEditingController(text: initial),
          onChanged: (v) => txt = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              onSave(txt);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E342E),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        title: const Text("To-Do & Notes"),
      ),
      body:Stack(
        children: [
          // 🌄 BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/bghp.png',
              fit: BoxFit.cover,
            ),
          ),

          // 📦 CONTENT
          Column(

            children: [
              // 🔍 SEARCH + SORT + FILTER
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: "Search..."),
                        onChanged: (v) => context.read<TodoNotesBloc>().add(SearchChanged(v)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // ✅ IMPORTANT
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => SafeArea(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  const Text("Sort", style: TextStyle(fontWeight: FontWeight.bold)),

                                  ListTile(
                                    title: const Text("A → Z"),
                                    onTap: () {
                                      context.read<TodoNotesBloc>().add(SortChanged(SortType.az));
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text("Z → A"),
                                    onTap: () {
                                      context.read<TodoNotesBloc>().add(SortChanged(SortType.za));
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text("Newest"),
                                    onTap: () {
                                      context.read<TodoNotesBloc>().add(SortChanged(SortType.newest));
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text("Oldest"),
                                    onTap: () {
                                      context.read<TodoNotesBloc>().add(SortChanged(SortType.oldest));
                                      Navigator.pop(context);
                                    },
                                  ),

                                  const Divider(),

                                  const Text("Filter To-Dos", style: TextStyle(fontWeight: FontWeight.bold)),
                                  DropdownButton<TodoStatusFilter>(
                                    isExpanded: true, // ✅ IMPORTANT
                                    value: todoFilter,
                                    onChanged: (v) => setState(() => todoFilter = v!),
                                    items: const [
                                      DropdownMenuItem(value: TodoStatusFilter.all, child: Text("All")),
                                      DropdownMenuItem(value: TodoStatusFilter.completed, child: Text("Completed")),
                                      DropdownMenuItem(value: TodoStatusFilter.pending, child: Text("Pending")),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  const Text("Filter Notes", style: TextStyle(fontWeight: FontWeight.bold)),
                                  DropdownButton<NotesContentFilter>(
                                    isExpanded: true, // ✅ IMPORTANT
                                    value: notesFilter,
                                    onChanged: (v) => setState(() => notesFilter = v!),
                                    items: const [
                                      DropdownMenuItem(value: NotesContentFilter.all, child: Text("All")),
                                      DropdownMenuItem(value: NotesContentFilter.withImage, child: Text("With Image / PDF")),
                                      DropdownMenuItem(value: NotesContentFilter.textOnly, child: Text("Text Only")),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        applyFilter();
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Apply"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  ],
                ),
              ),

              // 📃 LISTS
              Expanded(
                child: BlocBuilder<TodoNotesBloc, TodoNotesState>(
                  builder: (context, state) {
                    return ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        const Text("To-Dos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ...state.visibleTodos.map((d) => Slidable(
                          key: ValueKey(d.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                icon: Icons.edit,
                                backgroundColor: Colors.blue,
                                onPressed: (_) => editDialog(d['title'], (v) =>
                                    context.read<TodoNotesBloc>().add(EditTodo(uid, d.id, v))),
                              ),
                              SlidableAction(
                                icon: Icons.delete,
                                backgroundColor: Colors.red,
                                onPressed: (_) =>
                                    context.read<TodoNotesBloc>().add(DeleteTodo(uid, d.id)),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: d['isDone'],
                              onChanged: (v) => context.read<TodoNotesBloc>().add(ToggleTodo(uid, d.id, v!)),
                            ),
                            title: Text(d['title']),
                          ),
                        )),

                        const SizedBox(height: 24),
                        const Text("Notes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ...state.visibleNotes.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return Slidable(
                            key: ValueKey(d.id),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  icon: Icons.edit,
                                  backgroundColor: Colors.blue,
                                  onPressed: (_) => editDialog(data['text'] ?? "", (v) =>
                                      context.read<TodoNotesBloc>().add(EditNote(uid, d.id, v))),
                                ),
                                SlidableAction(
                                  icon: Icons.delete,
                                  backgroundColor: Colors.red,
                                  onPressed: (_) =>
                                      context.read<TodoNotesBloc>().add(DeleteNote(uid, d.id)),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: data['fileType'] == 'pdf'
                                  ? const Icon(Icons.picture_as_pdf, color: Colors.red)
                                  : data['fileType'] == 'image'
                                  ? const Icon(Icons.image, color: Colors.blue)
                                  : null,
                              title: Text(data['text'] ?? ""),
                              onTap: data['fileType'] == 'pdf'
                                  ? () {
                                if (kIsWeb) {
                                  final url = '${data['fileUrl']}?dl=1';
                                  launchUrl(
                                    Uri.parse(url),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                                else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PDFViewerScreen(url: data['fileUrl']),
                                    ),
                                  );
                                }
                              }
                                  : null,


                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: const Color(0xFF4E342E),
        foregroundColor: Colors.white,
        overlayOpacity: 0.3,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.check_box),
            label: 'Add To-Do',
            onTap: addTodo,
          ),
          SpeedDialChild(
            child: const Icon(Icons.note_add),
            label: 'Add Note',
            onTap: addNote,
          ),
          SpeedDialChild(
            child: const Icon(Icons.attach_file),
            label: 'Attach Note',
            onTap: attachNote,
          ),
        ],
      ),

    );
  }
}
