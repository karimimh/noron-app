import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/widgets/startup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NoronAppData noron = NoronAppData();
  bool appDataLoaded = false;

  @override
  void initState() {
    super.initState();
    noron.load().then((value) {
      setState(() {
        noron = value;
        appDataLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Colors.black,

        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(240, 240, 240, 1.0),
          foregroundColor: Colors.black,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: TextStyle(color: Colors.black),
            unselectedLabelStyle: TextStyle(color: Colors.grey),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed),

        // Define the default font family.
        fontFamily: 'BYekan',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        fontFamily: 'BYekan',
      ),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("fa", "IR"),
      ],
      locale: const Locale("fa", "IR"),
      home: Builder(builder: (context) {
        if (appDataLoaded) {
          return StartupPage(noron: noron);
        } else {
          return Container(
            color: Colors.white,
            child: const CircularProgressIndicator.adaptive(
              backgroundColor: Colors.black,
            ),
          );
        }
      }),
    );
  }
}
