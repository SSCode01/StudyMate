class ChatState {
  final List<Map<String, String>> messages;
  final bool loading;

  ChatState({
    required this.messages,
    required this.loading,
  });

  ChatState copyWith({
    List<Map<String, String>>? messages,
    bool? loading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
    );
  }
}
