import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SplashEvent {}
class StartSplash extends SplashEvent {}

abstract class SplashState {}
class SplashInitial extends SplashState {}
class SplashToHome extends SplashState {}
class SplashToLogin extends SplashState {}

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<StartSplash>((event, emit) async {
      await Future.delayed(const Duration(seconds: 3));

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        emit(SplashToHome());
      } else {
        emit(SplashToLogin());
      }
    });
  }
}
