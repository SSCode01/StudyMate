import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ProfileEvent {}

class LoadUserEvent extends ProfileEvent {}

class LogoutEvent extends ProfileEvent {}

class ProfileState {
  final User? user;
  final bool loggedOut;
  ProfileState({required this.user, required this.loggedOut});

  ProfileState copyWith({User? user, bool? loggedOut}) {
    return ProfileState(
      user: user ?? this.user,
      loggedOut: loggedOut ?? false,
    );
  }
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc()
      : super(ProfileState(user: FirebaseAuth.instance.currentUser, loggedOut: false)) {
    on<LoadUserEvent>((event, emit) {
      emit(ProfileState(user: FirebaseAuth.instance.currentUser, loggedOut: false));
    });

    on<LogoutEvent>((event, emit) async {
      await FirebaseAuth.instance.signOut();
      emit(ProfileState(user: null, loggedOut: true));
    });
  }
}
