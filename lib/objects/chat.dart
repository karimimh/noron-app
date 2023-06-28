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

  Chat withHeader() {
    Chat newChat = Chat();
    newChat.add(chatHeaderPersian, false, true);
    newChat.messages.addAll(messages);
    return newChat;
  }
}

class ChatGPTCompletion {
  final List<dynamic> completions;
  String get firstChoice {
    return completions[0]["message"]["content"];
  }

  const ChatGPTCompletion({required this.completions});

  @override
  String toString() {
    return firstChoice;
  }

  // factory ChatGPTCompletion.fromJson(Map<String, dynamic> d) {
  //   // print("COMPLETIONS: ${json['completions']}");
  //   // print("FIRST CHOICE: ${json['completions'][0]["message"]["content"]}");
  //   return ChatGPTCompletion(
  //       completions: d.containsKey('completions') ? d['completions'] : []);
  // }
}
