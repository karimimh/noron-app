import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class DropdownString {
  final List<String> choices;
  int currentIndex = 0;
  DropdownString(this.choices);
}

class CommandString {
  final List<Object> strings;

  CommandString(this.strings);

  String getFirstChoice() {
    String result = "";
    for (var obj in strings) {
      if (obj is String) {
        result += obj;
      } else if (obj is DropdownString) {
        result += obj.choices[0];
      } else {
        result += obj.toString();
      }
    }
    return result;
  }

  List<DropdownString> getDropDownStrings() {
    List<DropdownString> result = [];
    for (var string in strings) {
      if (string is DropdownString) {
        result.add(string);
      }
    }
    return result;
  }

  TextSpan getTextSpan(Function setState) {
    List<DropdownString> dropdownStrings = getDropDownStrings();
    int N = dropdownStrings.length;

    List<InlineSpan> children = [];

    int currentDDS = 0;
    for (var i = 0; i < strings.length; i++) {
      final element = strings[i];
      if (element is String) {
        children.add(TextSpan(text: element));
      } else if (element is DropdownString) {
        DropdownString elementToAdd = dropdownStrings[N - 1 - currentDDS];
        currentDDS += 1;
        children.add(WidgetSpan(
            child: PopupMenuButton(
          child: Text(
            elementToAdd.choices[elementToAdd.currentIndex],
            style: const TextStyle(color: Colors.blue),
          ),
          itemBuilder: (context) {
            var menuItems = [];
            for (var j = 0; j < elementToAdd.choices.length; j++) {
              menuItems.add(PopupMenuItem<int>(
                value: j,
                child: Text(elementToAdd.choices[j]),
                onTap: () {
                  setState(() {
                    elementToAdd.currentIndex = j;
                  });
                },
              ));
            }
            return <PopupMenuEntry<int>>[...menuItems];
          },
        )));
      }
    }
    return TextSpan(children: children);
  }
}

class Tool {
  final String title;
  final IconData icon;
  final List<CommandString> items;

  Tool(this.title, this.icon, this.items);
}

List<Tool> tools = [
  Tool(
    "خلاصه‌سازی",
    Icons.summarize_outlined,
    [
      CommandString([
        "متن زیر را ",
        DropdownString([
          "در یک جمله ",
          "در دو جمله ",
          "در سه جمله ",
          "در چهار جمله ",
          "در پنج جمله ",
          " "
        ]),
        "خلاصه کن.",
      ]),
      CommandString([
        "محتوای صفحه تارنمای زیر رو ",
        DropdownString([
          "در یک جمله ",
          "در دو جمله ",
          "در سه جمله ",
          "در چهار جمله ",
          "در پنج جمله ",
          " "
        ]),
        "خلاصه کن."
      ]),
    ],
  ),
  Tool(
    "ترجمه",
    Icons.translate,
    [
      CommandString([
        "متن زیر رو ",
        DropdownString([
          "به انگلیسی ",
          "به فارسی ",
          "به عربی ",
        ]),
        "ترجمه کن."
      ]),
      CommandString([
        "متن زیر رو ",
        DropdownString([
          "به انگلیسی ",
          "به فارسی ",
          "به عربی ",
        ]),
        "ترجمه کرده، سپس ",
        DropdownString([
          "در یک جمله ",
          "در دو جمله ",
          "در سه جمله ",
          "در چهار جمله ",
          "در پنج جمله ",
          " "
        ]),
        "خلاصه کن."
      ]),
    ],
  ),
  Tool(
    "داستان‌سرایی",
    Icons.edit_note,
    [
      CommandString([
        "یک داستان ",
        DropdownString([
          "طنز ",
          "جنایی",
          "تخیلی ",
          "علمی ",
          "کوتاه ",
          " ",
        ]),
        "با حداکثر ",
        DropdownString([
          "۱۰۰ کلمه ",
          "۲۵۰ کلمه ",
          "۵۰۰ کلمه ",
          "۱۰ جمله",
          "۲۰ جمله",
        ]),
        " بساز",
      ]),
      CommandString(["یک قصه کودکانه برای خواب بچه‌ها بگو"]),
      CommandString([
        "یک داستان ",
        DropdownString([
          "طنز ",
          "جنایی",
          "تخیلی ",
          "علمی ",
          "کوتاه ",
          " ",
        ]),
        "با حداکثر ",
        DropdownString([
          "۱۰۰ کلمه ",
          "۲۵۰ کلمه ",
          "۵۰۰ کلمه ",
          "۱۰ جمله",
          "۲۰ جمله",
        ]),
        " با موضوع زیر بساز",
      ]),
    ],
  ),
  Tool(
    "شعرگویی",
    Icons.history_edu,
    [
      CommandString(["یک شعر کوتاه در مورد ربات‌ها بگو"]),
      CommandString(["۱۰بیت شعر از اشعار حافظ انتخاب کن"]),
    ],
  ),
  Tool(
    "توضیح به زبان ساده",
    Icons.school_outlined,
    [
      CommandString(["هوش مصنوعی رو به زبان ساده توضیح بده"]),
      CommandString(["نحوه رخ دادن پدیده رعد و برق رو با جزئیات بیان کن"]),
      CommandString(["تعریف دقیق نویز در مهندسی رو بیان کن."]),
    ],
  ),
  Tool(
    "پست نویسی",
    Icons.post_add,
    [
      CommandString(["یک پست در خصوص میوه سیب برای شبکه اجتماعی توییتر بنویس"]),
    ],
  ),
  Tool(
    "ساخت کوییز",
    Icons.quiz_outlined,
    [
      CommandString(["یک کوییز در خصوص موضوع زبان برنامه‌نویسی پایتون بساز"]),
    ],
  ),
  Tool(
    "حل معما",
    Icons.check,
    [
      CommandString([
        "معمای زیر رو حل کن: در یک اتاق ۱۰۰ نفره به طور متوسط چند نفر روز تولدشان با من یکسان است؟"
      ]),
    ],
  ),
  Tool(
    "تحقیق و مقاله نویسی",
    Icons.article_outlined,
    [
      CommandString([
        "فرض کن تو یک دانش‌آموز دوره دبستان هستی. یک تحقیق در خصوص خطرناک‌ترین حیوانات دریایی بنویس"
      ]),
      CommandString(["یک مقاله در خصوص آینده هوش مصنوعی در زمینه آموزش بنویس"]),
      CommandString(
          ["یک تحقیق در خصوص مسائل حل نشده در حوزه نظریه اعداد بنویس."]),
    ],
  ),
  Tool(
    "رایانامه نویسی",
    Icons.email_outlined,
    [
      CommandString([
        "فرض کن تو یک دانشجوی دوره کارشناسی در رشته مهندسی کامپیوتر هستی. یک ایمیل برای استاد کامرانی بنویس که از او درخواست کنی مهلت تمارین را یک هفته به عقب بیاندازد. از این بهانه که این هفته آزمون دیگری داری استفاده کن."
      ]),
    ],
  ),
  Tool(
    "عنوان نویسی",
    Icons.title,
    [
      CommandString(["۵ عنوان برای متن زیر پیشنهاد کن. "]),
    ],
  ),
  Tool(
    "پیشنهاد ایده",
    Icons.lightbulb_outline,
    [
      CommandString(
          ["ایده‌های پژوهشی برای دوره دکترا در زمینه لیزرهای فوتونیک بده"]),
      CommandString(
          ["ایده‌های نو برای کسب درامد برای مهندس نرم‌افزار پیشنهاد بده"]),
    ],
  ),
  Tool(
    "برنامه‌ریزی",
    Icons.checklist,
    [
      CommandString(["یک برنامه غذایی برای لاغر شدن در طول یکماه طراحی کن."]),
    ],
  ),
  Tool(
    "تصحیح متن",
    Icons.spellcheck,
    [
      CommandString(["غلط‌های املایی متن زیر را اصلاح کن."]),
      CommandString(["متن زیر را از لحاظ نگارشی اصلاح کن"]),
    ],
  ),
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 1;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Center(
      child: Text(
        'خانه',
        style: optionStyle,
      ),
    ),
    ToolsListView(),
    Center(
      child: Text(
        'ابزار تصویری',
        style: optionStyle,
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        // textTheme: const TextTheme(
        //   displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        //   titleLarge: TextStyle(fontSize: 36, fontStyle: FontStyle.italic),
        //   bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Hind'),
        // ),
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
        appBar: AppBar(),
        body: _widgetOptions.elementAt(_selectedIndex),
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
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class ToolsListView extends StatelessWidget {
  const ToolsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tools.length,
      itemBuilder: (context, i) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: Text(
                tools[i].title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: Icon(tools[i].icon),
              trailing: const Icon(Icons.arrow_drop_down_rounded),
              children: <Widget>[
                Column(
                  children: _buildExpandableContent(tools[i], context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildExpandableContent(Tool tool, BuildContext context) {
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
                builder: (context) => SummarizerForm(command: item),
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

class SummarizerForm extends StatefulWidget {
  final CommandString command;
  const SummarizerForm({super.key, required this.command});

  @override
  State<SummarizerForm> createState() => _SummarizerFormState();
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({required this.userId, required this.id, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(userId: json['userId'], id: json['id'], title: json['title']);
  }
}

class _SummarizerFormState extends State<SummarizerForm> {
  final tffController = TextEditingController();
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
    tffController.addListener(_myListener);
  }

  @override
  void dispose() {
    tffController.dispose();
    super.dispose();
  }

  void _myListener() {
    // print(tffController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text.rich(
                widget.command.getTextSpan(setState),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                maxLength: 4000,
                minLines: 8,
                maxLines: null,
                controller: tffController,
                decoration: InputDecoration(
                    labelText: "متن خود را اینجا وارد کنید.",
                    filled: true,
                    fillColor: Colors.white,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    fetchAlbum();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("خلاصه کن"),
                  )),
              const SizedBox(
                height: 20,
              ),
              FutureBuilder(
                future: futureAlbum,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.black12,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        snapshot.data!.title,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.black12,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        '${snapshot.error!}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
            ],
          ),
        ));
  }
}

Future<Album> fetchAlbum() async {
  String url = 'https://jsonplaceholder.typicode.com/albums/1';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load the album');
  }
}
