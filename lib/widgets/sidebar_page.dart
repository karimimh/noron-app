import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/util/text_utils.dart';

import '../api/openai.dart';
import '../objects/chat.dart';

class SidebarPage extends StatefulWidget {
  final NoronAppData noron;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final void Function(int chatIndex)? onChatItemTapped;

  const SidebarPage({
    super.key,
    required this.noron,
    this.onChatItemTapped,
    required this.scaffoldKey,
  });

  @override
  State<SidebarPage> createState() => _SidebarPageState();
}

class _SidebarPageState extends State<SidebarPage> {
  bool _isRefreshing = false;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text("تاریخچه"),
        actions: [
          IconButton(
              onPressed: _isRefreshing
                  ? null
                  : () {
                      refreshChats(context);
                    },
              icon: Icon(
                Icons.refresh,
                color: _isRefreshing ? Colors.grey[400] : Colors.black,
              ))
        ],
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
          var chatTitle =
              chat.title.isEmpty ? chat.messages.first.text : chat.title;
          bool isRTL = detectLanguage(string: chatTitle) == "fa";
          return Builder(builder: (context) {
            return GestureDetector(
              onTap: () {
                if (widget.onChatItemTapped != null) {
                  widget.onChatItemTapped!(index);
                }
              },
              onLongPress: () {
                // show popup menu:
                if (!_isRefreshing) {
                  showPopupMenu(context, chat.id ?? -1);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[100],
                  // boxShadow: const [
                  //   BoxShadow(blurRadius: 1, color: Colors.black)
                  // ],
                ),
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                child: Text(
                  chatTitle,
                  textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  overflow: TextOverflow.fade,
                ),
              ),
            );
          });
        },
      ),
    );
  }

  void refreshChats(BuildContext context) {
    setState(() {
      _isRefreshing = true;
    });
    return widget.noron.refresh(
      onCompletion: () {
        setState(() {
          _isRefreshing = false;
        });
      },
      onError: () {
        setState(() {
          _isRefreshing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطا در به‌روزرسانی!'),
          ),
        );
      },
    );
  }

  void showPopupMenu(BuildContext context, int chatID) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox popupButton = context.findRenderObject() as RenderBox;
    final Offset offset =
        popupButton.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + popupButton.size.height,
        offset.dx + popupButton.size.width,
        offset.dy + popupButton.size.height + 10,
      ),
      items: const [
        PopupMenuItem(
          value: 1,
          child: Text("حذف"),
        ),
        PopupMenuItem(
          value: 2,
          child: Text("تغییر عنوان"),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      // Handle menu item selection
      if (value != null) {
        switch (value) {
          case 1:
            setState(() {
              _isRefreshing = false;
            });
            deleteChat(user: widget.noron.user, chatID: chatID).then((value) {
              print("Chat with id=$chatID successfully deleted!");
              if (widget.noron.user.chats.length == 1) {
                widget.noron.user.chats.add(Chat());
              }
              widget.noron.user.chats
                  .removeWhere((element) => element.id == chatID);
              widget.noron.currentChatIndex =
                  widget.noron.user.chats.length - 1;
              setState(() {});
              refreshChats(context);
            }).onError((error, stackTrace) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('خطا در حذف چت'),
                ),
              );
            });
            break;

          case 2:
            _showTitleInputDialog(context, (userTitle) {
              changeChatTitle(
                  user: widget.noron.user,
                  chat: widget.noron.user.chats
                      .where((element) => element.id == chatID)
                      .first,
                  title: userTitle);
            });
            break;
        }
      }
    });
  }

  void _showTitleInputDialog(
      BuildContext context, Function(String) completion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TitleInputDialog(
          onTitleSet: (String title) {
            // Handle the entered title here
            setState(() {
              completion(title);
            });
          },
        );
      },
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

class TitleInputDialog extends StatefulWidget {
  final Function(String) onTitleSet;

  const TitleInputDialog({super.key, required this.onTitleSet});

  @override
  State<TitleInputDialog> createState() => _TitleInputDialogState();
}

class _TitleInputDialogState extends State<TitleInputDialog> {
  late TextEditingController _textController;
  bool _rtl = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(() {
      _rtl = detectRTL(string: _textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تغییر عنوان چت'),
      content: TextField(
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign: _rtl ? TextAlign.right : TextAlign.left,
        controller: _textController,
        decoration: const InputDecoration(hintText: 'عنوان'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Call the onTitleSet callback and pass the entered title
            widget.onTitleSet(_textController.text);
            Navigator.of(context).pop();
          },
          child: Text(
            'تأیید',
            style: TextStyle(color: Colors.teal[300]),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'لغو',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
