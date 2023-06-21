import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:noron_front/user.dart';
import 'tools.dart';
import 'text_tool.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'chat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<User> futureUser;
  int _selectedTabIndex = 1;

  final nameTFController = TextEditingController();
  final emailTFController = TextEditingController();
  final passwordTFController = TextEditingController();

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    futureUser = Future(() => User("", "", ""));
    _loadUser();
  }

  @override
  void dispose() {
    nameTFController.dispose();
    emailTFController.dispose();
    passwordTFController.dispose();
    super.dispose();
  }

  //Loading counter value on start
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String userName = (prefs.getString('userName') ?? '');
    String userEmail = (prefs.getString('userEmail') ?? '');
    String userToken = (prefs.getString('userToken') ?? '');

    futureUser = Future<User>(() => User(userEmail, userName, userToken));
  }

  //Incrementing counter after click
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('userName', user.name);
      prefs.setString('userEmail', user.email);
      prefs.setString('userToken', user.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      FutureBuilder(
          future: futureUser,
          builder: (context, snapshot) {
            return Home(user: snapshot.data ?? User("", "", ""));
          }),
      FutureBuilder(
          future: futureUser,
          builder: (context, snapshot) {
            return ToolsListView(user: snapshot.data ?? User("", "", ""));
          }),
      const Center(
        child: Text(
          'ابزار تصویری',
          style: optionStyle,
        ),
      ),
    ];

    return MaterialApp(
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
      home: Scaffold(
        appBar: AppBar(
            // title: ,
            ),
        body: widgetOptions.elementAt(_selectedTabIndex),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(240, 240, 240, 1.0),
                  ),
                  child: Builder(builder: (context) {
                    return TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text('ورود'),
                                    content: SizedBox(
                                      height: 250,
                                      child: Column(
                                        children: [
                                          TextField(
                                            autofocus: true,
                                            keyboardType: TextInputType.name,
                                            maxLength: 100,
                                            minLines: 1,
                                            maxLines: 1,
                                            controller: nameTFController,
                                            textDirection: TextDirection.ltr,
                                            decoration: InputDecoration(
                                                labelText: "نام",
                                                filled: true,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                          ),
                                          TextField(
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            maxLength: 100,
                                            minLines: 1,
                                            maxLines: 1,
                                            controller: emailTFController,
                                            textDirection: TextDirection.ltr,
                                            decoration: InputDecoration(
                                                labelText: "ایمیل",
                                                filled: true,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                          ),
                                          TextField(
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            maxLength: 100,
                                            minLines: 1,
                                            maxLines: 1,
                                            controller: passwordTFController,
                                            textDirection: TextDirection.ltr,
                                            decoration: InputDecoration(
                                                labelText: "رمز عبور",
                                                filled: true,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          try {
                                            futureUser = login(
                                                nameTFController.text,
                                                emailTFController.text,
                                                passwordTFController.text);
                                          } catch (e) {
                                            print("Failed signin");
                                          }
                                        },
                                        child: const Text(
                                          'تأیید',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text(
                                          'لغو',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                    actionsAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                  ));
                        },
                        child: FutureBuilder(
                            future: futureUser,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.email.isNotEmpty) {
                                _saveUser(snapshot.data!);
                                return Text(snapshot.data!.email);
                              } else {
                                return const Text("ورود");
                              }
                            }));
                  })),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'خانه',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.title),
              label: 'ابزار متنی',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.image),
              label: 'ابزار تصویری',
            ),
          ],
          currentIndex: _selectedTabIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  final User user;
  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final tffController = TextEditingController();
  final modalTFController = TextEditingController();
  Chat chat = Chat([
    ChatMessage(
        "سلام. من یک مدل هوش مصنوعی هستم که می‌توانم خدمات متنی به شما ارائه دهم.",
        false),
  ]);

  @override
  void dispose() {
    tffController.dispose();
    modalTFController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: chat.length(),
            itemBuilder: (context, index) {
              return ChatBubble(
                chatMessage: chat.messages[index],
              );
            },
            padding: const EdgeInsets.only(bottom: 70.0),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                          hintText: "متن خود را اینجا وارد کنید...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                      controller: modalTFController,
                      onSubmitted: (value) {
                        setState(() {
                          if (value.isNotEmpty) {
                            chat.add(value, true);
                            chat.add("", false);
                            chat.last().isFetching = true;
                            sendMessages();
                            modalTFController.clear();
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      setState(() {
                        if (modalTFController.text.isNotEmpty) {
                          chat.add(modalTFController.text, true);
                          chat.add("", false);
                          chat.last().isFetching = true;
                          sendMessages();
                          modalTFController.clear();
                        }
                      });
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(
                      Icons.send,
                      color: Colors.blue,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendMessages() {
    List<Map<String, dynamic>> messages = [
      {
        "role": "system",
        "content": "Assistant is a helpful language model created by OpenAI"
      },
    ];

    for (var i = 1; i < chat.length() - 1; i++) {
      var chatMessage = chat.messages[i];
      if (chatMessage.isUser) {
        messages.add({"role": "user", "content": chatMessage.message});
      } else {
        messages.add({"role": "assistant", "content": chatMessage.message});
      }
    }

    fetchChatGPTCompletion(widget.user.token, messages, 0.7).then((value) {
      setState(() {
        chat.last().message = value.completion;
        chat.last().isFetching = false;
      });
      return;
    });
  }
}

class ToolsListView extends StatelessWidget {
  final User user;
  const ToolsListView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: textTools.length,
      itemBuilder: (context, i) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: Text(
                textTools[i].title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: Icon(textTools[i].icon),
              trailing: const Icon(Icons.arrow_drop_down_rounded),
              children: <Widget>[
                Column(
                  children: _buildExpandableContent(textTools[i], context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildExpandableContent(TextTool tool, BuildContext context) {
    List<Widget> columnContent = [];

    for (var item in tool.items) {
      columnContent.add(
        ListTile(
            title: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                item.getFirstChoice(),
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TextToolForm(
                    apiKey: user.token,
                    command: item,
                    needsTextFormField: item.needsTextFormField,
                    textFormFieldLabelText: item.textFormFieldLabelText,
                    textFormFieldMinLines: item.textFormFieldMinLines,
                    buttonText: item.buttonText),
              ));
            }),
      );
    }

    return columnContent;
  }
}

// class ToolsGridView extends StatelessWidget {
//   const ToolsGridView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       crossAxisCount: 2,
//       children: List.generate(toolNames.length, (index) {
//         return InkWell(
//           child: Card(
//             margin: const EdgeInsets.all(8.0),
//             child: Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       toolNames[index],
//                       style: const TextStyle(fontSize: 30),
//                       textDirection: TextDirection.rtl,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 10),
//                     Icon(toolIcons[index]),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           onTap: () {
//             Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => const SummarizerForm(),
//             ));
//           },
//         );
//       }),
//     );
//   }
// }

// User

