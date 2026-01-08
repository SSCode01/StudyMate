import 'package:bloc/bloc.dart';

class NavigationEvent {
  final int index;
  NavigationEvent(this.index);
}

class NavigationState {
  final int index;
  NavigationState(this.index);
}

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState(0)) {
    on<NavigationEvent>((event, emit) {
      emit(NavigationState(event.index));
    });
  }
}
