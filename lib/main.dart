import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_init/app_init_bloc.dart';
import 'auth/auth_bloc.dart';
import 'splash/splash_bloc.dart';
import 'splash/splash_screen.dart';
import 'home/navigation/navigation_bloc.dart';
import 'home/tasks/task_bloc.dart';
import 'home/calendar/calendar_bloc.dart';
import 'home/profile/profile_bloc.dart';
import 'home/chat/chat_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppInitBloc()..add(InitializeApp())),
        BlocProvider(create: (_) => SplashBloc()),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => TaskBloc()),
        BlocProvider(create: (_) => CalendarBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => ChatBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StudyMate',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AppInitWrapper(),
      ),
    );
  }
}

class AppInitWrapper extends StatelessWidget {
  const AppInitWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppInitBloc, AppInitState>(
      builder: (context, state) {
        if (state is AppInitLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AppInitSuccess) {
          return const SplashScreen();
        }

        if (state is AppInitFailure) {
          return Scaffold(
            body: Center(child: Text("Error: ${state.error}")),
          );
        }

        return const SizedBox();
      },
    );
  }
}
