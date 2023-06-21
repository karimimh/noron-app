import 'package:flutter/material.dart';

class ChatMessage {
  String message = "";
  bool isUser = true;
  bool isFetching = false;

  ChatMessage(this.message, this.isUser);
}

class Chat {
  List<ChatMessage> messages;

  Chat(this.messages);

  int length() => messages.length;

  void add(String message, bool isUser) {
    messages.add(ChatMessage(message, isUser));
  }

  ChatMessage last() {
    return messages.last;
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({Key? key, required this.chatMessage}) : super(key: key);

  final ChatMessage chatMessage;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (chatMessage.isFetching) {
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(16.0),
          child: const CircularProgressIndicator.adaptive(),
        );
      } else {
        return Padding(
          // asymmetric padding for the chat bubble
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Align(
            alignment: chatMessage.isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: chatMessage.isUser ? Colors.blue[200] : Colors.grey[300],
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              margin: chatMessage.isUser
                  ? const EdgeInsetsDirectional.only(start: 0.0, end: 50.0)
                  : const EdgeInsetsDirectional.only(start: 50.0, end: 0.0),
              child: Text(
                chatMessage.message,
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        );
      }
    });
  }
}
