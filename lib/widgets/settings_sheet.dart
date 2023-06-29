import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/widgets/user/login_page.dart';

class SetttingsSheet extends StatefulWidget {
  final NoronAppData noron;
  const SetttingsSheet({super.key, required this.noron});

  @override
  State<SetttingsSheet> createState() => _SetttingsSheetState();
}

class _SetttingsSheetState extends State<SetttingsSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("خروج"),
            leading: const Icon(Icons.logout),
            onTap: () {
              widget.noron.deleteData();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) {
                  return LoginPage(noron: widget.noron);
                },
              ));
            },
          )
        ],
      ),
    );
  }
}
