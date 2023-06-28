import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/widgets/sidebar_page.dart';

import '../objects/chat.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  final NoronAppData noron;
  const HomePage({super.key, required this.noron});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scController = ScrollController();
  bool _isShowingSideBar = false;

  @override
  void initState() {
    super.initState();
    widget.noron.currentChatIndex = widget.noron.user.chats.length - 1;
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
        if (_isShowingSideBar && delta < -10) {
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
                            widget.noron.user.chats.add(Chat());
                            widget.noron.save();
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
                        opacity: _isShowingSideBar ? 0.5 : 1.0,
                        child: IgnorePointer(
                            ignoring: _isShowingSideBar,
                            child: ChatPage(
                              noron: widget.noron,
                            )),
                      ),
                      IgnorePointer(
                        ignoring: !_isShowingSideBar,
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

  void _toggleSideBar() {
    _scController
        .animateTo(
      _isShowingSideBar
          ? _scController.position.maxScrollExtent
          : _scController.position.minScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    )
        .then((value) {
      setState(() {
        _isShowingSideBar = !_isShowingSideBar;
      });
    });
  }
}
