import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/widgets/sidebar_page.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isShowingSideBar = false;

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
      onHorizontalDragEnd: (details) {
        double delta = details.velocity.pixelsPerSecond.dx;
        if (isShowingSideBar && delta < -10) {
          _toggleSideBar();
        }
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        controller: _scController,
        child: Row(
          children: [
            SizedBox(
                width: screenWidth * 0.666,
                child: SidebarPage(
                  noron: widget.noron,
                  onChatItemTapped: (chatIndex) {
                    _toggleSideBar(
                      completion: () {
                        widget.noron.currentChatIndex = chatIndex;
                      },
                    );
                  },
                  scaffoldKey: _scaffoldKey,
                )),
            SizedBox(
              width: screenWidth,
              child: Scaffold(
                key: _scaffoldKey,
                body: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 2,
                    leading: IconButton(
                        onPressed: () {
                          _toggleSideBar();
                        },
                        icon: const Icon(Icons.menu)),
                    actions: [
                      IconButton(
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
                          icon: const Icon(Icons.cleaning_services)),
                    ],
                  ),
                  body: Stack(
                    children: [
                      Opacity(
                        opacity: isShowingSideBar ? 0.5 : 1.0,
                        child: IgnorePointer(
                            ignoring: isShowingSideBar,
                            child: ChatPage(
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

  // void _repositionSideBar() {
  //   if (_scController.hasClients) {
  //     _scController.jumpTo(_isShowingSideBar
  //         ? _scController.position.maxScrollExtent
  //         : _scController.position.minScrollExtent);
  //   }
  // }
}
