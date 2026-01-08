import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
}

class SignupEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  SignupEvent(this.name, this.email, this.password, this.confirmPassword);
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.email.trim(),
          password: event.password.trim(),
        );
        emit(AuthSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? "Login failed"));
      }
    });

    on<SignupEvent>((event, emit) async {
      emit(AuthLoading());

      if (event.password.trim() != event.confirmPassword.trim()) {
        emit(AuthFailure("Passwords do not match"));
        return;
      }

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: event.email.trim(),
          password: event.password.trim(),
        );
        emit(AuthSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthFailure(e.message ?? "Signup failed"));
      }
    });
  }
}
