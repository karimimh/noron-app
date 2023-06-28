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
  String _selectedLanguage = 'فارسی';

  @override
  void initState() {
    super.initState();
    _selectedLanguage =
        (widget.noron.appLanguage == AppLanguage.persian) ? "فارسی" : "English";
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
            leading: const Icon(Icons.language),
            title: const Text('زبان'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                  widget.noron.appLanguage = (_selectedLanguage == "English")
                      ? AppLanguage.english
                      : AppLanguage.persian;
                });
              },
              items: <String>['فارسی', 'English']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
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
