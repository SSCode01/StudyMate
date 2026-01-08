import 'package:bloc/bloc.dart';

class Task {
  final String title;
  final bool isDone;

  Task({required this.title, required this.isDone});

  Task copyWith({String? title, bool? isDone}) {
    return Task(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}

abstract class TaskEvent {}

class AddTask extends TaskEvent {
  final String title;
  AddTask(this.title);
}

class EditTask extends TaskEvent {
  final int index;
  final String newTitle;
  EditTask(this.index, this.newTitle);
}

class DeleteTask extends TaskEvent {
  final int index;
  DeleteTask(this.index);
}

class ToggleTask extends TaskEvent {
  final int index;
  ToggleTask(this.index);
}

class TaskState {
  final List<Task> tasks;
  TaskState(this.tasks);

  double get progress {
    if (tasks.isEmpty) return 0;
    final done = tasks.where((t) => t.isDone).length;
    return done / tasks.length;
  }
}

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskState([])) {
    on<AddTask>((event, emit) {
      final updated = List<Task>.from(state.tasks)
        ..add(Task(title: event.title, isDone: false));
      emit(TaskState(updated));
    });

    on<EditTask>((event, emit) {
      final updated = List<Task>.from(state.tasks);
      updated[event.index] =
          updated[event.index].copyWith(title: event.newTitle);
      emit(TaskState(updated));
    });

    on<DeleteTask>((event, emit) {
      final updated = List<Task>.from(state.tasks)..removeAt(event.index);
      emit(TaskState(updated));
    });

    on<ToggleTask>((event, emit) {
      final updated = List<Task>.from(state.tasks);
      final t = updated[event.index];
      updated[event.index] = t.copyWith(isDone: !t.isDone);
      emit(TaskState(updated));
    });
  }
}
