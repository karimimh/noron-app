import 'dart:convert';
import 'package:http/http.dart' as http;

import '../objects/chat.dart';
import '../objects/user.dart';

Future<ChatGPTCompletion> fetchChatGPTCompletion(
    {required User user,
    required List<Map<String, String>> messages,
    required double temperature}) async {
  String url = 'http://185.226.119.155:8000/openai/completion/';
  final response = await http.post(Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Token ${user.token}'
      },
      body: jsonEncode({'messages': messages, 'temperature': temperature}));

  if (response.statusCode == 200) {
    var decoded = jsonDecode(utf8.decode(response.bodyBytes));

    return Future.value(
        ChatGPTCompletion(completions: decoded["completions"] ?? []));
  } else {
    print(response.statusCode);
    print(response.body);
    return Future.error(response.body);
  }
}

Future<ChatGPTCompletion> fetchChatResponse(
    {required Chat chat, required User user}) {
  List<Map<String, String>> messages = [
    {
      "role": "system",
      "content": "Assistant is a helpful language model created by OpenAI"
    },
  ];

  for (var i = 0; i < chat.length() - 1; i++) {
    var chatMessage = chat.messages[i];
    if (chatMessage.isUser) {
      messages.add({"role": "user", "content": chatMessage.text});
    } else {
      messages.add({"role": "assistant", "content": chatMessage.text});
    }
  }

  return fetchChatGPTCompletion(
      user: user, messages: messages, temperature: 0.7);
}
