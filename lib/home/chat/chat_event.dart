abstract class ChatEvent {}

class SendChatMessage extends ChatEvent {
  final String text;
  SendChatMessage(this.text);
}
