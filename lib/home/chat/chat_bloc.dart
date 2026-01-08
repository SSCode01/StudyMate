import 'package:bloc/bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  late GenerativeModel model;

  ChatBloc() : super(ChatState(messages: [], loading: false)) {
    final key = dotenv.env['GEMINI_API_KEY'];
    model = GenerativeModel(model: "gemini-2.5-flash", apiKey: key!);

    on<SendChatMessage>((event, emit) async {
      final updated = List<Map<String, String>>.from(state.messages)
        ..add({"sender": "user", "text": event.text});

      emit(state.copyWith(messages: updated, loading: true));

      try {
        final r = await model.generateContent([Content.text(event.text)]);
        final reply = r.text ?? "No response from Gemini.";
        updated.add({"sender": "bot", "text": reply});
      } catch (e) {
        updated.add({"sender": "bot", "text": "Error: $e"});
      }

      emit(state.copyWith(messages: updated, loading: false));
    });
  }
}
