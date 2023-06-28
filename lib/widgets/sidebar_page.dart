import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/util/text_utils.dart';

import '../objects/chat.dart';

class SidebarPage extends StatefulWidget {
  final NoronAppData noron;
  const SidebarPage({super.key, required this.noron});

  @override
  State<SidebarPage> createState() => _SidebarPageState();
}

class _SidebarPageState extends State<SidebarPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Chat> get _userChats {
    List<Chat> c = [];
    for (var chat in widget.noron.user.chats) {
      if (chat.messages.isNotEmpty) {
        c.add(chat);
      }
    }
    return c;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text("تاریخچه"),
      ),
      backgroundColor: Colors.white,
      // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      // floatingActionButton: FloatingActionButton(
      //     backgroundColor: Colors.white,
      //     child: const Icon(
      //       Icons.settings,
      //       color: Colors.black,
      //     ),
      //     onPressed: () {
      //       if (_scaffoldKey.currentContext != null) {
      //         showModalBottomSheet(
      //           shape: const RoundedRectangleBorder(
      //               borderRadius: BorderRadius.only(
      //                   topLeft: Radius.circular(20),
      //                   topRight: Radius.circular(20))),
      //           context: _scaffoldKey.currentContext!,
      //           builder: (context) {
      //             return WillPopScope(
      //                 onWillPop: () {
      //                   setState(() {});
      //                   return Future(() => true);
      //                 },
      //                 child: SetttingsSheet(noron: widget.noron));
      //           },
      //         );
      //       }
      //     }),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        itemCount: _userChats.length,
        itemBuilder: (context, i) {
          int index = _userChats.length - 1 - i;
          Chat chat = _userChats[index];
          var lastMessageText = chat.messages.last.text;
          bool isRTL = detectLanguage(string: lastMessageText) == "fa";
          return GestureDetector(
            onTap: () {
              widget.noron.currentChatIndex = index;
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(blurRadius: 1, color: Colors.black)
                ],
              ),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                lastMessageText,
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                overflow: TextOverflow.fade,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Align(
//   alignment: Alignment.bottomRight,
//   child: SizedBox(
//     height: 60,
//     child: Row(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.settings),
//           onPressed: () {
//             if (_scaffoldKey.currentContext != null) {
//               showModalBottomSheet(
//                 shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20))),
//                 context: _scaffoldKey.currentContext!,
//                 builder: (context) {
//                   return WillPopScope(
//                       onWillPop: () {
//                         setState(() {});
//                         return Future(() => true);
//                       },
//                       child: SetttingsSheet(noron: widget.noron));
//                 },
//               );
//             }
//           },
//         ),
//       ],
//     ),
//   ),
// )
