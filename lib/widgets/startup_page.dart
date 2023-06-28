import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/widgets/user/login_page.dart';

import '../api/user_api.dart';
import '../objects/user.dart';
import 'home_page.dart';

class StartupPage extends StatefulWidget {
  final NoronAppData noron;
  const StartupPage({super.key, required this.noron});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  late Future<User> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = login(widget.noron.user);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.hasToken()) {
            widget.noron.user = snapshot.data!;
            Future.microtask(
                () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) {
                        return HomePage(noron: widget.noron);
                      },
                    )));
          } else if (snapshot.hasError) {
            Future.microtask(
                () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) {
                        return LoginPage(noron: widget.noron);
                      },
                    )));
          }
          return Container(
            color: Colors.white,
            child: const CircularProgressIndicator.adaptive(
              backgroundColor: Colors.black,
            ),
          );
        });
  }
}
