import 'dart:convert';
import 'package:http/http.dart' as http;

import '../objects/chat.dart';
import '../objects/user.dart';

Future<Chat> fetchChatResponse(
    {required Chat chat, required User user, double? temperature}) {
  if (chat.messages.length == 2) {
    // one user. one pending AI
    return _fetchSingleMessageChatCompletion(
        user: user, chat: chat, temperature: temperature ?? 0.7);
  } else {
    return _fetchMultiMessageChatCompletion(
        user: user, chat: chat, temperature: temperature ?? 0.7);
  }
}

Future<Chat> _fetchSingleMessageChatCompletion(
    {required User user,
    required Chat chat,
    required double temperature}) async {
  String url = 'http://185.226.119.155:8000/openai/completion/';
  final response = await http.post(Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Token ${user.token}'
      },
      body: jsonEncode(
          {'messages': chat.prependedMessages(), 'temperature': temperature}));

  if (response.statusCode == 200) {
    var decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return Future.value(Chat.fromJSON(decoded));
  } else {
    print(response.statusCode);
    print(response.body);
    return Future.error(response.body);
  }
}

Future<Chat> _fetchMultiMessageChatCompletion(
    {required User user,
    required Chat chat,
    required double temperature}) async {
  String url = 'http://185.226.119.155:8000/openai/chats/${chat.id}/';
  final response = await http.put(Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Token ${user.token}'
      },
      body: jsonEncode(
          {'messages': chat.prependedMessages(), 'temperature': temperature}));

  if (response.statusCode == 200) {
    var decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return Future.value(Chat.fromJSON(decoded));
  } else {
    print(response.statusCode);
    print(response.body);
    return Future.error(response.body);
  }
}

Future<bool> deleteChat({required User user, required int chatID}) async {
  String url = 'http://185.226.119.155:8000/openai/chats/$chatID/';
  final response = await http.delete(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': 'Token ${user.token}'
    },
  );
  if (response.statusCode != 204) {
    print(response.statusCode);
    print(response.body);
    return Future.error(response.body);
  }
  return Future.value(true);
}

Future<Chat> fetchChat({required User user, required int chatID}) async {
  String url = 'http://185.226.119.155:8000/openai/chats/$chatID/';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': 'Token ${user.token}'
    },
  );
  if (response.statusCode != 200) {
    print(response.statusCode);
    print(response.body);
    return Future.error(response.body);
  }
  var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

  Chat chat = Chat.fromJSON(decodedResponse);
  return Future.value(chat);
}

Future<List<Chat>> fetchAllChats({required User user}) async {
  String url = 'http://185.226.119.155:8000/openai/chats/all/';
  List<Chat> chats = [];
  while (url.isNotEmpty) {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Token ${user.token}'
      },
    );
    if (response.statusCode != 200) {
      print(response.statusCode);
      // print(response.body);
      return Future.error(response.body);
    }
    final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

    url = decodedResponse["next"] ?? ""; // url of next page of results
    final List chatsJSON = decodedResponse["results"];

    for (var i = 0; i < chatsJSON.length; i++) {
      final chatJSON = chatsJSON[i];
      Chat chat = Chat.fromJSON(chatJSON);
      chats.add(chat);
    }
  }
  return Future.value(chats);
}

Future<Chat> changeChatTitle(
    {required User user, required Chat chat, required String title}) async {
  String url = 'http://185.226.119.155:8000/openai/chats/${chat.id}/set-title/';
  final response = await http.post(Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Token ${user.token}'
      },
      body: jsonEncode({'title': title}));

  if (response.statusCode == 200) {
    chat.title = title;
    return Future.value(chat);
  } else {
    print(response.statusCode);
    print(response.body);
    return Future.error(response.body);
  }
}
