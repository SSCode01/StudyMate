import 'package:equatable/equatable.dart';

class CalendarState extends Equatable {
  final bool loading;

  /// Map< Date, List<Event> >
  final Map<DateTime, List<Map<String, dynamic>>> events;

  const CalendarState({
    required this.loading,
    required this.events,
  });

  factory CalendarState.initial() {
    return const CalendarState(
      loading: false,
      events: {},
    );
  }

  CalendarState copyWith({
    bool? loading,
    Map<DateTime, List<Map<String, dynamic>>>? events,
  }) {
    return CalendarState(
      loading: loading ?? this.loading,
      events: events ?? this.events,
    );
  }

  @override
  List<Object?> get props => [loading, events];
}
