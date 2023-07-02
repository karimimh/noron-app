import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/widgets/side_page.dart';

import '../objects/chat.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  final NoronAppData noron;
  const HomePage({super.key, required this.noron});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _scController = ScrollController();
  final sidepageKey = GlobalKey<SidePageState>();

  var chatpageKey = GlobalKey<ChatPageState>();
  bool get isShowingSideBar => widget.noron.isShowingSidePage;
  set isShowingSideBar(bool newValue) {
    widget.noron.isShowingSidePage = newValue;
  }

  double get anchoredScrollPosition => isShowingSideBar
      ? _scController.position.minScrollExtent
      : _scController.position.maxScrollExtent;
  double get draggedScrollPosition => anchoredScrollPosition + dragDelta;
  double dragDelta = 0;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scController.jumpTo(_scController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() {
          isDragging = true;
          dragDelta = 0;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          if ((draggedScrollPosition + details.delta.dx <=
                  _scController.position.maxScrollExtent) &&
              (draggedScrollPosition + details.delta.dx >=
                  _scController.position.minScrollExtent)) {
            dragDelta += details.delta.dx;
          }
          _rejumpSideBar();
        });
      },
      onHorizontalDragEnd: (details) {
        // double totalScrollDistance = _scController.position.maxScrollExtent -
        //     _scController.position.minScrollExtent;
        setState(() {
          bool wasNotShowingSideBar = !isShowingSideBar;
          if (-dragDelta >= screenWidth * 0.2) {
            isShowingSideBar = true;
          } else if (dragDelta >= screenWidth * 0.2) {
            isShowingSideBar = false;
          }
          isDragging = false;
          dragDelta = 0;
          _rejumpSideBar(
            animated: true,
            completion: wasNotShowingSideBar && isShowingSideBar
                ? () {
                    // if (sidepageKey.currentContext != null) {
                    //   sidepageKey.currentState
                    //       ?.refreshChats(sidepageKey.currentContext!);
                    // }
                  }
                : null,
          );
        });
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        controller: _scController,
        child: Row(
          children: [
            SizedBox(
                width: screenWidth * 0.8,
                child: SidePage(
                  key: sidepageKey,
                  noron: widget.noron,
                  onChatItemTapped: (chatIndex) {
                    _toggleSideBar(
                      completion: () {
                        widget.noron.currentChatIndex = chatIndex;
                        if (chatpageKey.currentState != null) {
                          Future.delayed(const Duration(seconds: 1),
                              chatpageKey.currentState!.scrollTheChat);
                        }
                      },
                    );
                  },
                )),
            SizedBox(
              width: screenWidth,
              child: Scaffold(
                body: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 1,
                    leading: IconButton(
                        onPressed: () {
                          _toggleSideBar(
                            completion: () {
                              // if (sidepageKey.currentContext != null) {
                              //   sidepageKey.currentState
                              //       ?.refreshChats(sidepageKey.currentContext!);
                              // }
                            },
                          );
                        },
                        icon: const Icon(Icons.menu)),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton.icon(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.black12,
                                foregroundColor: Colors.black),
                            onPressed: () {
                              if (widget.noron.currentChat.isEmpty()) {
                                return;
                              }
                              if (!widget.noron.user.chats.last.isEmpty()) {
                                widget.noron.user.chats.add(Chat());
                              }
                              setState(() {
                                widget.noron.currentChatIndex =
                                    widget.noron.user.chats.length - 1;
                              });
                            },
                            icon: const Icon(CupertinoIcons.add_circled),
                            label: const Text("بحث جدید")),
                      ),
                    ],
                  ),
                  body: Stack(
                    children: [
                      Opacity(
                        opacity: isShowingSideBar ? 0.5 : 1.0,
                        child: IgnorePointer(
                            ignoring: isShowingSideBar,
                            child: ChatPage(
                              key: chatpageKey,
                              noron: widget.noron,
                            )),
                      ),
                      IgnorePointer(
                        ignoring: !isShowingSideBar,
                        child: GestureDetector(
                          onTap: () {
                            _toggleSideBar();
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ), // drawer: MyDrawer(noron: noron),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSideBar({void Function()? completion}) {
    _scController
        .animateTo(
      isShowingSideBar
          ? _scController.position.maxScrollExtent
          : _scController.position.minScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    )
        .then((value) {
      setState(() {
        isShowingSideBar = !isShowingSideBar;
        if (completion != null) {
          completion();
        }
      });
    });
  }

  void _rejumpSideBar({bool animated = false, void Function()? completion}) {
    if (_scController.hasClients) {
      if (isDragging) {
        if (animated) {
          _scController
              .animateTo(
            draggedScrollPosition,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          )
              .then((value) {
            if (completion != null) {
              completion();
            }
          });
        } else {
          _scController.jumpTo(draggedScrollPosition);
        }
      } else {
        if (animated) {
          _scController
              .animateTo(
            draggedScrollPosition,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          )
              .then((value) {
            if (completion != null) {
              completion();
            }
          });
        } else {
          _scController.jumpTo(anchoredScrollPosition);
        }
      }
    }
  }
}
