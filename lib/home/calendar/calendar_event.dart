import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCalendarRange extends CalendarEvent {
  final String uid;
  final DateTime start;
  final DateTime end;

  LoadCalendarRange(this.uid, this.start, this.end);

  @override
  List<Object?> get props => [uid, start, end];
}

class AddCalendarEvent extends CalendarEvent {
  final String uid;
  final DateTime day;
  final String title;

  AddCalendarEvent(this.uid, this.day, this.title);

  @override
  List<Object?> get props => [uid, day, title];
}

class EditCalendarEvent extends CalendarEvent {
  final String uid;
  final DateTime day;
  final String eventId;
  final String title;

  EditCalendarEvent(this.uid, this.day, this.eventId, this.title);

  @override
  List<Object?> get props => [uid, day, eventId, title];
}

class DeleteCalendarEvent extends CalendarEvent {
  final String uid;
  final DateTime day;
  final String eventId;

  DeleteCalendarEvent(this.uid, this.day, this.eventId);

  @override
  List<Object?> get props => [uid, day, eventId];
}
