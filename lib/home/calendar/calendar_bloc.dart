import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(CalendarState.initial()) {
    on<LoadCalendarRange>(_loadRange);
    on<AddCalendarEvent>(_addEvent);
    on<EditCalendarEvent>(_editEvent);
    on<DeleteCalendarEvent>(_deleteEvent);
  }

  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // ------------------------ LOAD RANGE ------------------------
  Future<void> _loadRange(
      LoadCalendarRange e, Emitter<CalendarState> emit) async {
    emit(state.copyWith(loading: true));

    final Map<DateTime, List<Map<String, dynamic>>> all = {};

    final ref = FirebaseFirestore.instance
        .collection("Users")
        .doc(e.uid)
        .collection("calendar_events");

    final dates = await ref.get();

    for (var d in dates.docs) {
      final dt = DateTime.tryParse(d.id);
      if (dt == null) continue;

      if (dt.isBefore(e.start) || dt.isAfter(e.end)) continue;

      final events = await ref.doc(d.id).collection("events").get();

      all[DateTime.utc(dt.year, dt.month, dt.day)] = events.docs
          .map((x) => {"id": x.id, "title": x["title"]})
          .toList();
    }

    emit(state.copyWith(loading: false, events: all));
  }

  // ------------------------ ADD EVENT ------------------------
  Future<void> _addEvent(
      AddCalendarEvent e, Emitter<CalendarState> emit) async {
    final key = _fmt(e.day);

    final dateDoc = FirebaseFirestore.instance
        .collection("Users")
        .doc(e.uid)
        .collection("calendar_events")
        .doc(key);

    // 🔥 IMPORTANT: Ensure parent doc exists
    await dateDoc.set({"exists": true}, SetOptions(merge: true));

    await dateDoc.collection("events").add({
      "title": e.title,
      "created": FieldValue.serverTimestamp(),
    });

    add(LoadCalendarRange(
        e.uid,
        DateTime(e.day.year, e.day.month, 1),
        DateTime(e.day.year, e.day.month + 1, 0)));
  }

  // ------------------------ EDIT EVENT ------------------------
  Future<void> _editEvent(
      EditCalendarEvent e, Emitter<CalendarState> emit) async {
    final key = _fmt(e.day);

    final dateDoc = FirebaseFirestore.instance
        .collection("Users")
        .doc(e.uid)
        .collection("calendar_events")
        .doc(key);

    // 🔥 Ensure parent exists
    await dateDoc.set({"exists": true}, SetOptions(merge: true));

    await dateDoc.collection("events").doc(e.eventId).update({
      "title": e.title,
      "edited": FieldValue.serverTimestamp(),
    });

    add(LoadCalendarRange(
        e.uid,
        DateTime(e.day.year, e.day.month, 1),
        DateTime(e.day.year, e.day.month + 1, 0)));
  }

  // ------------------------ DELETE EVENT ------------------------
  Future<void> _deleteEvent(
      DeleteCalendarEvent e, Emitter<CalendarState> emit) async {
    final key = _fmt(e.day);

    final dateDoc = FirebaseFirestore.instance
        .collection("Users")
        .doc(e.uid)
        .collection("calendar_events")
        .doc(key);

    // 🔥 Ensure parent exists
    await dateDoc.set({"exists": true}, SetOptions(merge: true));

    await dateDoc.collection("events").doc(e.eventId).delete();

    add(LoadCalendarRange(
        e.uid,
        DateTime(e.day.year, e.day.month, 1),
        DateTime(e.day.year, e.day.month + 1, 0)));
  }
}
