import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'auth/auth_bloc.dart';
import 'login_screen.dart';
import 'todo_notes_screen.dart';
import 'chat_screen.dart';
import 'home/navigation/navigation_bloc.dart';
import 'home/tasks/task_bloc.dart';
import 'home/calendar/calendar_bloc.dart';
import 'home/profile/profile_bloc.dart';
import 'home/todo_notes/todo_notes_bloc.dart';
import 'package:studymate/home/calendar/calendar_bloc.dart';
import 'package:studymate/home/calendar/calendar_event.dart';
import 'package:studymate/home/calendar/calendar_state.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        final pages = [
          const _HomeTab(),
          const _MaterialsTab(),
          const _ProfileTab(),
          const _CalendarTab(),
        ];

        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text("Study Mate", style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF4A2E1B),
            centerTitle: true,
            actions: [
              IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
              IconButton(icon: const Icon(Icons.notifications, color: Colors.white), onPressed: () {}),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Color(0xFF4A2E1B)),
                  child: Text('Study Mate Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),

                ListTile(
                  leading: const Icon(Icons.checklist),
                  title: const Text('To-Do List & Notes'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => TodoNotesBloc(),
                          child: const TodoNotesScreen(),
                        ),
                      ),
                    );
                  },
                ),

                ListTile(leading: const Icon(Icons.settings), title: const Text('Settings')),
                ListTile(
                  leading: const Icon(Icons.smart_toy),
                  title: const Text('ChatBot'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                  },
                ),
                ListTile(leading: const Icon(Icons.help), title: const Text('Help')),
                ListTile(leading: const Icon(Icons.info), title: const Text('About')),
              ],
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/bghp.png', fit: BoxFit.cover),
              ),
              pages[navState.index],
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navState.index,
            onTap: (i) => context.read<NavigationBloc>().add(NavigationEvent(i)),
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Materials'),
              BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
            ],
          ),
        );
      },
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, taskState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.orange.shade100,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('"Consistency is the key to success. Study a little every day!"',
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(height: 20),
              CarouselSlider(
                options: CarouselOptions(height: 150, autoPlay: true, enlargeCenterPage: true),
                items: [
                  "Tip: Revise daily for 10 mins",
                  "Reminder: Submit assignment by Friday",
                  "Stay Hydrated 💧 while studying",
                ].map((text) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(text,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text("Quick Access", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _qa(Icons.note, "Notes"),
                  _qa(Icons.assignment, "Assignments"),
                  _qa(Icons.schedule, "Schedule"),
                  _qa(Icons.quiz, "Quizzes"),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Your Task Progress",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              LinearPercentIndicator(
                animation: true,
                lineHeight: 18,
                animationDuration: 900,
                percent: taskState.progress,
                barRadius: const Radius.circular(10),
                center: Text("${(taskState.progress * 100).round()}%",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                progressColor: Colors.green,
                backgroundColor: Colors.orange.shade100,
                linearStrokeCap: LinearStrokeCap.roundAll,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Today's Tasks",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: () {
                      String x = "";
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Add New Task"),
                          content: TextField(
                            autofocus: true,
                            onChanged: (v) => x = v,
                            decoration: const InputDecoration(hintText: "Task title"),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                            ElevatedButton(
                              onPressed: () {
                                if (x.trim().isNotEmpty) {
                                  context.read<TaskBloc>().add(AddTask(x.trim()));
                                }
                                Navigator.pop(context);
                              },
                              child: const Text("Add"),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                children: List.generate(taskState.tasks.length, (i) {
                  final t = taskState.tasks[i];
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => context.read<TaskBloc>().add(DeleteTask(i)),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          onPressed: (_) {
                            String x = t.title;
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Edit Task"),
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
                                        context.read<TaskBloc>().add(EditTask(i, x.trim()));
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Save"),
                                  )
                                ],
                              ),
                            );
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child: Card(
                      child: CheckboxListTile(
                        title: Text(t.title,
                            style: TextStyle(
                                decoration: t.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none)),
                        value: t.isDone,
                        onChanged: (_) => context.read<TaskBloc>().add(ToggleTask(i)),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _qa(IconData i, String t) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(i, size: 40, color: Colors.brown),
              const SizedBox(height: 8),
              Text(t, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  const _MaterialsTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        children: List.generate(
          6,
              (i) => Card(
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: Center(child: Text("Subject ${i + 1}", style: const TextStyle(fontSize: 18))),
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state.loggedOut) {
          return const LoginScreen();
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.user?.email ?? "Guest", style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.exit_to_app),
                label: const Text("Logout"),
                onPressed: () => context.read<ProfileBloc>().add(LogoutEvent()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  CalendarFormat f = CalendarFormat.month;
  DateTime focus = DateTime.now();
  DateTime? sel;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<ProfileBloc>().state.user?.uid;
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, cal) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: focus,
                    calendarFormat: f,
                    selectedDayPredicate: (d) => isSameDay(sel, d),
                    eventLoader: (day) => cal.events[DateTime.utc(day.year, day.month, day.day)] ?? [],
                    onDaySelected: (s, fDay) {
                      setState(() {
                        sel = s;
                        focus = fDay;
                      });
                    },
                    onFormatChanged: (x) => setState(() => f = x),
                    onPageChanged: (newFocus) {
                      final start = DateTime(newFocus.year, newFocus.month, 1);
                      final end = DateTime(newFocus.year, newFocus.month + 1, 0);
                      if (uid != null) {
                        context.read<CalendarBloc>().add(LoadCalendarRange(uid, start, end));
                      }
                      setState(() => focus = newFocus);
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (uid != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Add event"),
                          onPressed: () {
                            String x = "";
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Add Event"),
                                content: TextField(
                                  autofocus: true,
                                  onChanged: (v) => x = v,
                                  decoration: const InputDecoration(hintText: "Event title"),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (sel != null && x.trim().isNotEmpty) {
                                        context.read<CalendarBloc>().add(
                                          AddCalendarEvent(uid, sel!, x.trim()),
                                        );
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Add"),
                                  )
                                ],
                              ),
                            );
                          },
                        )
                    ],
                  ),
                  sel == null
                      ? const Text("Select a date")
                      : _EventList(sel!, cal, uid)
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

class _EventList extends StatelessWidget {
  final DateTime day;
  final CalendarState state;
  final String? uid;

  const _EventList(this.day, this.state, this.uid);

  @override
  Widget build(BuildContext context) {
    final key = DateTime.utc(day.year, day.month, day.day);
    final list = state.events[key] ?? [];

    if (uid == null) return const Text("Sign in to use events.");
    if (list.isEmpty) return const Text("No events for this date.");

    return Column(
      children: list.map((e) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.event_note),
            title: Text(e["title"]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    String x = e["title"];
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Edit Event"),
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
                                context.read<CalendarBloc>().add(
                                  EditCalendarEvent(uid!, day, e["id"], x.trim()),
                                );
                              }
                              Navigator.pop(context);
                            },
                            child: const Text("Save"),
                          )
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    context.read<CalendarBloc>().add(
                      DeleteCalendarEvent(uid!, day, e["id"]),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
