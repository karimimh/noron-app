class ChatMessage {
  String text = "";
  var isRTL = true;
  bool isUser = true;
  bool isFetching = false;

  ChatMessage({required this.text, required this.isUser, required this.isRTL});
}

class Chat {
  static const chatHeaderPersian =
      "سلام. من یک مدل هوش مصنوعی هستم که می‌توانم خدمات متنی به شما ارائه دهم.";
  static const chatHeaderEnglish =
      "Hi! I am an AI language model that can give you text-based services.";

  List<ChatMessage> messages = [];
  int length() => messages.length;

  void add(String message, bool isUser, isRTL) {
    messages.add(ChatMessage(text: message, isUser: isUser, isRTL: isRTL));
  }

  ChatMessage last() {
    return messages.last;
  }
}

class ChatGPTCompletion {
  final String completion;
  final String error;

  const ChatGPTCompletion({required this.completion, required this.error});

  factory ChatGPTCompletion.fromJson(Map<String, dynamic> json) {
    return ChatGPTCompletion(
        completion: json['result'] ?? "", error: json['error'] ?? "");
  }
}
