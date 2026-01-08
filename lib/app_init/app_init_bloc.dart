import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../firebase_options.dart';

abstract class AppInitEvent {}
class InitializeApp extends AppInitEvent {}

abstract class AppInitState {}
class AppInitInitial extends AppInitState {}
class AppInitLoading extends AppInitState {}
class AppInitSuccess extends AppInitState {}
class AppInitFailure extends AppInitState {
  final String error;
  AppInitFailure(this.error);
}

class AppInitBloc extends Bloc<AppInitEvent, AppInitState> {
  AppInitBloc() : super(AppInitInitial()) {
    on<InitializeApp>((event, emit) async {
      emit(AppInitLoading());

      try {
        await dotenv.load(fileName: ".env");

        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        emit(AppInitSuccess());
      } catch (e) {
        emit(AppInitFailure(e.toString()));
      }
    });
  }
}
