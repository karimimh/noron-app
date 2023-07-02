import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/util/text_utils.dart';
import 'package:noron_front/widgets/text_tools_list.dart';

import '../api/openai.dart';
import '../objects/chat.dart';

class ChatPage extends StatefulWidget {
  final NoronAppData noron;
  const ChatPage({super.key, required this.noron});

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final tffController = TextEditingController();
  final scrollController = ScrollController();
  bool isFetchingCompletion = false;
  bool inputIsRTL = false;
  final _focusNode = FocusNode();

  Chat get chat => widget.noron.currentChat;
  set chat(Chat newValue) {
    widget.noron.currentChat = newValue;
  }

  @override
  void initState() {
    super.initState();
    tffController.addListener(() {
      setState(() {
        inputIsRTL = detectRTL(string: tffController.text);
      });
    });
    _focusNode.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollTheChat();
    });
  }

  @override
  void dispose() {
    tffController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        controller: scrollController,
        itemCount: chat.length(),
        itemBuilder: (context, index) {
          final message = chat.messages[index];
          final text = message.text;
          final isUser = message.isUser;
          final isLast = index == (chat.messages.length - 1);
          var isRTL = (isLast && isFetchingCompletion) && (index > 0)
              ? detectRTL(string: chat.messages[index - 1].text)
              : detectRTL(string: text);
          return widget.noron.bubbledTheme
              ? chatBubble(context, isUser, isLast, isRTL, text)
              : chatTile(context, isUser, isLast, isRTL, text);
        },
        padding: const EdgeInsets.only(bottom: 10),
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.ltr,
        child: inputPannel(),
      ),
    );
  }

  Widget chatTile(
      BuildContext context, bool isUser, bool isLast, bool isRTL, String text) {
    final richText = (isFetchingCompletion && isLast)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:
                isRTL ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: const [
              SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator.adaptive()),
            ],
          )
        : getRichText(
            text, Colors.black, isRTL ? TextAlign.right : TextAlign.left);
    var personImage =
        isUser ? 'assets/images/person_filled.png' : 'assets/images/openai.png';
    var userIconWidget = Container(
      decoration: BoxDecoration(
        color: isUser ? Colors.grey : const Color(0xFF01C380),
        borderRadius: BorderRadius.circular(3),
        // border: Border.all(width: 1, color: Colors.black),
      ),
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: ImageIcon(
        AssetImage(personImage),
        size: 25,
        color: Colors.white,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 1,
              offset: const Offset(0, 1))
        ],
        color: isUser ? Colors.white : const Color(0xFFF7F7F8),
      ),
      padding: isRTL
          ? const EdgeInsets.fromLTRB(16, 16, 0, 16)
          : const EdgeInsets.fromLTRB(0, 16, 16, 16),
      margin: const EdgeInsets.only(bottom: 1.0),
      child: Row(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userIconWidget,
          Expanded(child: richText),
        ],
      ),
    );
  }

  ChatBubble chatBubble(
      BuildContext context, bool isUser, bool isLast, bool isRTL, String text) {
    final bubbleType =
        isUser ? BubbleType.sendBubble : BubbleType.receiverBubble;
    final bubbleAlignment =
        isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser
        ? Colors.blue[400]
        : const Color(0xFFFFFFFF); //const Color(0xffE7E7ED);

    final chatBubbleChild = (isFetchingCompletion && isLast)
        ? const CircularProgressIndicator.adaptive()
        : getRichText(
            text, Colors.black, isUser ? TextAlign.right : TextAlign.left);
    return ChatBubble(
      clipper: ChatBubbleClipper4(type: bubbleType),
      alignment: bubbleAlignment,
      elevation: 5,
      shadowColor: Colors.black,
      margin: const EdgeInsets.only(top: 20, right: 10, left: 10),
      backGroundColor: bubbleColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: chatBubbleChild,
      ),
    );
  }

  Widget inputPannel() {
    return Container(
      decoration: const BoxDecoration(
          border: BorderDirectional(top: BorderSide(color: Colors.black12))),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          builder: (context) {
                            return ToolsList(noron: widget.noron);
                            // return ToolsListView(noron: widget.noron);
                          },
                        ).then((value) {
                          setState(() {
                            if (value is List<String>) {
                              tffController.text = value[0];
                            }
                          });
                        });
                      },
                      icon: const Icon(
                        CupertinoIcons.list_bullet,
                        color: Colors.black,
                      )),
                  Expanded(child: buildInputTF()),
                ],
              ),
            ),
          ]),
    );
  }

  TextField buildInputTF() {
    TextAlign textFieldAlignment = TextAlign.left;
    if (tffController.text.isEmpty) {
      textFieldAlignment = TextAlign.center;
    } else if (inputIsRTL) {
      textFieldAlignment = TextAlign.right;
    }

    return TextField(
      minLines: 1,
      maxLines: 10,
      autofocus: false,
      textAlign: textFieldAlignment,
      textDirection: inputIsRTL ? TextDirection.rtl : TextDirection.ltr,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      decoration: InputDecoration(
        filled: true,
        suffixIcon: IconButton(
          onPressed: isFetchingCompletion || tffController.text.isEmpty
              ? null
              : () => processUserInput(tffController.text),
          icon: const Icon(
            CupertinoIcons.arrow_up_circle_fill,
            color: Colors.green,
            size: 22,
          ),
        ),
        hintText: "تایپ کنید",
        hintStyle: const TextStyle(
          color: Colors.black54,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
      controller: tffController,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(color: Colors.black),
    );
  }

  void processUserInput(String text) {
    FocusManager.instance.primaryFocus?.unfocus();
    chat.add(ChatMessage(text: text, isUser: true));
    chat.add(ChatMessage(text: "", isUser: false));
    setState(() {
      isFetchingCompletion = true;
    });
    fetchChatResponse(chat: chat, user: widget.noron.user).then((fetchedChat) {
      setState(() {
        chat = fetchedChat;
        isFetchingCompletion = false;
        Future.delayed(const Duration(milliseconds: 500), scrollTheChat);
        scrollTheChat();
      });
    }).onError((error, stackTrace) {
      print(
          "BBBBB\nError when fetching chat-completion!:\n${error.toString()}\n$stackTrace");
      setState(() {
        isFetchingCompletion = false;
        chat.removeLast();
        chat.removeLast();
      });
    });
    tffController.clear();
  }

  void scrollTheChat() {
    print("Chat Auto Scroll called");
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
  }
}
