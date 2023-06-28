import 'package:noron_front/util/text_utils.dart';

import '../objects/chat.dart';
import '../objects/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<User> createUserAndSendMail({
  required String name,
  required String email,
  required String password,
}) async {
  const String createUserUrl = 'http://185.226.119.155:8000/user/create/';
  const String sendMailUrl = 'http://185.226.119.155:8000/user/sendmail/';
  final createResponse = await http.post(Uri.parse(createUserUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password
      }));
  var data = jsonDecode(createResponse.body);
  if (createResponse.statusCode == 201) {
    User u = User(
        id: data["id"], email: data["email"], name: data["name"], token: "");
    // now send the mail:
    final sendMailResponse = await http.post(Uri.parse(sendMailUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': u.name,
          'email': u.email,
          'password': password,
          'user_id': u.id,
        }));
    if (sendMailResponse.statusCode == 200) {
      return Future.value(u);
    } else {
      print(sendMailResponse.statusCode);
      print(sendMailResponse.body);
      return Future.error(sendMailResponse.body);
    }
  } else {
    print(createResponse.statusCode);
    print(createResponse.body);
    if (data.containsKey('email') &&
        data['email'] is List &&
        data['email'][0] == "user with this email already exists.") {
      return Future.error("کاربری با این ایمیل قبلا ثبت نام کرده است");
    }
    return Future.error(createResponse.body);
  }
}

Future<bool> resendMail({
  required String email,
}) async {
  const String sendMailUrl = 'http://185.226.119.155:8000/user/sendmail/';
  final sendMailResponse = await http.post(Uri.parse(sendMailUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
      }));
  if (sendMailResponse.statusCode == 200) {
    return Future.value(true);
  } else {
    print(sendMailResponse.statusCode);
    print(sendMailResponse.body);
    return Future.error(sendMailResponse.body);
  }
}

Future<bool> activateUser({
  required int id,
  required String confirmationToken,
}) async {
  const String activateUserUrl = 'http://185.226.119.155:8000/user/activate/';
  final response = await http.post(
    Uri.parse(activateUserUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'user_id': id,
      'confirmation_token': confirmationToken
    }),
  );
  if (response.statusCode == 200) {
    return Future.value(true);
  } else if (response.statusCode == 404) {
    return Future.error("کاربر پیدا نشد");
  } else {
    return Future.error(response.body);
  }
}

Future<User> fetchMe(User u) async {
  print("FETCHME_STARTED with token: ${u.token}");
  const String meUrl = 'http://185.226.119.155:8000/user/me/';
  final response = await http.get(
    Uri.parse(meUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': 'Token ${u.token}',
    },
  );
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    User newUser = User(
        id: data["id"],
        email: data["email"],
        name: data["name"],
        token: u.token);
    return Future.value(newUser);
  } else {
    print('FETCHME_ERROR: ${response.statusCode} ${response.body}');
    return Future.error(response.body);
  }
}

Future<String> createToken({
  required String email,
  required String password,
}) async {
  const String getTokenUrl = 'http://185.226.119.155:8000/user/token/';
  final response = await http.post(Uri.parse(getTokenUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}));
  var data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return data["token"];
  } else {
    print(response.statusCode);
    if (data.containsKey('non_field_errors') &&
        data['non_field_errors'] is List &&
        data['non_field_errors'][0] ==
            "Unable to authenticate with provided credentials") {
      return Future.error(
          "مشخصات کاربر نادرست بوده یا اینکه هنوز ایمیل خود را فعال نکرده است.");
    }
    return Future.error(response.body);
  }
}

Future<bool> resetPassword({
  required String email,
}) async {
  const String url = 'http://185.226.119.155:8000/user/reset-password/';
  final response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
      }));
  if (response.statusCode == 200) {
    return Future.value(true);
  } else {
    print(response.statusCode);
    print(response.body);
    return Future.error(response.body);
  }
}

Future<List<Chat>> fetchAllChats({required User user}) async {
  String url = 'http://185.226.119.155:8000/openai/chats/all/';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': 'Token ${user.token}'
    },
  );

  if (response.statusCode == 200) {
    var decoded = jsonDecode(utf8.decode(response.bodyBytes));
    List results = decoded["results"];

    List<Chat> chats = [];
    for (var item in results) {
      Chat chat = Chat();
      String jsonString = item["messages"].replaceAll("'", '"');
      var messages = jsonDecode(jsonString);
      for (var message in messages) {
        if (message["role"] != "system") {
          chat.messages.add(ChatMessage(
              text: message["content"],
              isUser: message["role"] == "user",
              isRTL: detectLanguage(string: message["content"]) == "fa"));
        }
      }

      chat.messages.add(ChatMessage(
          text: item["completions"][0]["message"]["content"],
          isUser: false,
          isRTL: detectLanguage(
                  string: item["completions"][0]["message"]["content"]) ==
              "fa"));
      chats.add(chat);
    }
    // print(chats.length);
    return Future.value(chats);
  } else {
    print(response.statusCode);
    print(response.body);
    return Future.error(response.body);
  }
}

Future<User> login(User u) async {
  try {
    User user = await fetchMe(u);
    // now fetchAllChats
    List<Chat> chats = await fetchAllChats(user: user);
    chats.add(Chat());
    user.chats = chats;
    print(chats.length);
    return Future.value(user);
  } catch (e) {
    print(e);
    return Future.error(e);
  }
}
