import 'dart:convert';
import 'package:http/http.dart' as http;

import '../objects/chat.dart';

Future<ChatGPTCompletion> fetchChatGPTCompletion(
    apiKey, messages, temperature) async {
  print(jsonEncode(messages));
  String url = 'http://185.226.119.155:8000/chatgptcompletion/';
  final response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Token $apiKey'
      },
      body: jsonEncode(<String, String>{
        'messages': json.encode(messages),
        'temperature': '$temperature'
      }));

  if (response.statusCode == 200) {
    return ChatGPTCompletion.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)));
  } else {
    print(response.statusCode);
    print(response.body);
    throw Exception('Failed to load the chatgpt-completion');
  }
}

void fetchChatResponse(
    {required Chat chat,
    required String token,
    required void Function(ChatGPTCompletion) onCompletion,
    required void Function(ChatGPTCompletion) onError}) {
  List<Map<String, dynamic>> messages = [
    {
      "role": "system",
      "content": "Assistant is a helpful language model created by OpenAI"
    },
  ];

  for (var i = 1; i < chat.length() - 1; i++) {
    var chatMessage = chat.messages[i];
    if (chatMessage.isUser) {
      messages.add({"role": "user", "content": chatMessage.text});
    } else {
      messages.add({"role": "assistant", "content": chatMessage.text});
    }
  }

  fetchChatGPTCompletion(token, messages, 0.7).then((value) {
    if (value.error.isNotEmpty) {
      onCompletion(value);
    } else {
      onError(value);
    }

    return;
  });
}
