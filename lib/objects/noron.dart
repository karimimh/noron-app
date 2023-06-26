import 'package:noron_front/objects/tools.dart';
import 'package:noron_front/objects/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat.dart';

class NoronAppData {
  //Saved:
  User user = User(email: '', name: '', token: '', id: -1);
  AppLanguage appLanguage = AppLanguage.persian;

  //Not Saved:
  List<bool> isExpanded =
      List<bool>.generate(textTools.length, (index) => true);
  Chat get chat => user.chats.last;

  bool isAnActiveUserLoggedIn() {
    return user.email.isNotEmpty && user.token.isNotEmpty;
  }

  Future<NoronAppData> load() async {
    final prefs = await SharedPreferences.getInstance();

    String userName = (prefs.getString('userName') ?? '');
    String userEmail = (prefs.getString('userEmail') ?? '');
    String userToken = (prefs.getString('userToken') ?? '');
    String lang =
        (prefs.getString('appLanguage') ?? AppLanguage.persian.toString());

    user = User(email: userEmail, name: userName, token: userToken, id: -1);
    final appLanguageOptional = getLanguageFromString(lang);
    if (appLanguageOptional != null) {
      appLanguage = appLanguageOptional;
    }
    print("Loaded AppData");

    return Future(() => this);
  }

  Future<void> save() async {
    print("Saving AppData");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', user.name);
    prefs.setString('userEmail', user.email);
    prefs.setString('userToken', user.token);
    prefs.setString('appLanguage', appLanguage.toString());
  }

  bool isRTL() {
    return appLanguage == AppLanguage.persian;
  }
}

enum AppLanguage {
  persian,
  english,
}

AppLanguage? getLanguageFromString(String langString) {
  try {
    return AppLanguage.values
        .firstWhere((color) => color.toString() == langString);
  } catch (e) {
    return null;
  }
}
