import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';

import 'chat_page.dart';
import 'settings_sheet.dart';

class HomePage extends StatefulWidget {
  final NoronAppData noron;
  const HomePage({super.key, required this.noron});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                if (_scaffoldKey.currentContext != null) {
                  showModalBottomSheet(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    context: _scaffoldKey.currentContext!,
                    builder: (context) {
                      return WillPopScope(
                          onWillPop: () {
                            setState(() {});
                            return Future(() => true);
                          },
                          child: SetttingsSheet(noron: widget.noron));
                    },
                  );
                }
              },
            )
          ],
        ),
        body: ChatPage(noron: widget.noron),
        // drawer: MyDrawer(noron: noron),
      ),
    );
  }
}
