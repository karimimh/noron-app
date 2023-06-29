import 'package:noron_front/api/user_api.dart';
import 'package:noron_front/objects/tools.dart';
import 'package:noron_front/objects/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat.dart';

class NoronAppData {
  //Saved:
  User user = User(email: '', name: '', token: '', id: -1);

  //Not Saved:
  List<bool> isExpanded =
      List<bool>.generate(textTools.length, (index) => true);

  bool isAnActiveUserLoggedIn() {
    return user.email.isNotEmpty && user.token.isNotEmpty;
  }

  int currentChatIndex = 0;

  Chat get currentChat => user.chats[currentChatIndex];
  List<ChatMessage> get currentChatMessages => currentChat.messages;
  ChatMessage? get latestChatMessage =>
      currentChatMessages.isEmpty ? null : currentChatMessages.last;

  Future<NoronAppData> load() async {
    final prefs = await SharedPreferences.getInstance();

    String userName = (prefs.getString('userName') ?? '');
    String userEmail = (prefs.getString('userEmail') ?? '');
    String userToken = (prefs.getString('userToken') ?? '');

    user = User(email: userEmail, name: userName, token: userToken, id: -1);
    print("Loaded AppData");

    return Future(() => this);
  }

  Future<void> save() async {
    print("Saving AppData");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', user.name);
    prefs.setString('userEmail', user.email);
    prefs.setString('userToken', user.token);
  }

  Future<void> deleteData() async {
    print("Deleting all AppData");
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userName');
    prefs.remove('userEmail');
    prefs.remove('userToken');
    prefs.remove('appLanguage');
  }

  void refresh({Function()? onCompletion, Function()? onError}) {
    refetchUserData(user).then((value) {
      user = value;
      if (onCompletion != null) {
        onCompletion();
      }
    }).onError((error, stackTrace) {
      if (onError != null) {
        onError();
      }
    });
  }
}
