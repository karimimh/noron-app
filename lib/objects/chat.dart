class ChatMessage {
  String text = "";
  bool isUser = true;

  ChatMessage({required this.text, required this.isUser});
}

class Chat {
  int? id;
  List<ChatMessage> messages = [];
  String title = "";
  int length() => messages.length;

  Chat({this.id});

  void add(ChatMessage message) {
    messages.add(message);
  }

  ChatMessage last() {
    return messages.last;
  }

  void removeLast() {
    if (messages.isNotEmpty) {
      messages.removeLast();
    }
  }

  bool isEmpty() {
    return messages.isEmpty;
  }

  @override
  String toString() {
    String result = "";
    for (var msg in messages) {
      result += "${msg.isUser ? 'USER: ' : 'GPT: '} ${msg.text}\n";
    }
    return result;
  }

  factory Chat.fromJSON(dynamic chatJSON) {
    Chat chat = Chat(id: chatJSON["id"]);
    chat.title = chatJSON["title"];
    final chatMessages = chatJSON["messages"];
    for (var chatMessage in chatMessages) {
      if (chatMessage["role"] != "system") {
        chat.add(ChatMessage(
            text: chatMessage["content"],
            isUser: chatMessage["role"] == "user"));
      }
    }
    chat.add(ChatMessage(
      text: chatJSON["completions"][0]["message"]["content"],
      isUser: false,
    ));
    return chat;
  }

  /*
  * prepends messages of chat with a system message to be sent to the openai
  */
  List<Map<String, String>> prependedMessages() {
    List<Map<String, String>> result = [
      {
        "role": "system",
        "content": "Assistant is a helpful language model created by OpenAI"
      },
    ];

    for (var i = 0; i < length(); i++) {
      var chatMessage = messages[i];
      if (chatMessage.text.isEmpty) {
        continue;
      }
      if (chatMessage.isUser) {
        result.add({"role": "user", "content": chatMessage.text});
      } else {
        result.add({"role": "assistant", "content": chatMessage.text});
      }
    }
    return result;
  }
}
