import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';

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
    return WillPopScope(
      onWillPop: () {
        widget.noron.save();
        return Future(() => true);
      },
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey)],
          color: Colors.white,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('زبان'),
                trailing: DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                      widget.noron.appLanguage =
                          (_selectedLanguage == "English")
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
            ],
          ),
        ),
      ),
    );
  }
}
