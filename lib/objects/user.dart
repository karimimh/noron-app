import 'chat.dart';

class User {
  int id;
  String name;
  String email;
  String token;

  bool isActivated = false;
  List<Chat> chats = [Chat()];

  User(
      {required this.id,
      required this.email,
      required this.name,
      required this.token});

  bool isCreated() {
    return (id > 0) && email.isNotEmpty;
  }

  bool hasToken() {
    return token.isNotEmpty;
  }
}
