import 'dart:convert';

import 'package:http/http.dart' as http;

class User {
  String name;
  String email;
  String token;

  User(this.email, this.name, this.token);
}

Future<User> login(String name, String email, String password) async {
  String url = 'http://45.90.74.46:8000/user/create/';
  final response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password
      }));

  if (response.statusCode == 201) {
    // get a token
    url = 'http://45.90.74.46:8000/user/token/';
    final tokenResponse = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}));
    if (tokenResponse.statusCode == 200) {
      User u = User(email, name, jsonDecode(tokenResponse.body)["token"]);
      print(u.email);
      return u;
    } else {
      print(response.statusCode);
      print(response.body);
    }
  } else {
    print(response.statusCode);
    print(response.body);
  }
  throw Exception('Failed to register user');
}
