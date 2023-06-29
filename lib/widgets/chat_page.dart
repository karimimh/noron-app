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
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final tffController = TextEditingController();
  final scrollController = ScrollController();
  bool isFetchingCompletion = false;
  bool inputIsRTL = false;
  final _focusNode = FocusNode();

  Chat get chat => widget.noron.currentChat;
  set chat(Chat newValue) {
    widget.noron.user.chats.last = newValue;
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
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 95),
            child: ListView.builder(
              controller: scrollController,
              itemCount: chat.length(),
              itemBuilder: (context, index) {
                final message = chat.messages[index];
                final text = message.text;
                final isUser = message.isUser;

                final bubbleType =
                    isUser ? BubbleType.sendBubble : BubbleType.receiverBubble;
                final bubbleAlignment =
                    isUser ? Alignment.centerRight : Alignment.centerLeft;
                final bubbleColor = isUser
                    ? Colors.blue[400]
                    : const Color(0xFFFFFFFF); //const Color(0xffE7E7ED);

                final chatBubbleChild =
                    (isFetchingCompletion && index == chat.messages.length - 1)
                        ? const CircularProgressIndicator.adaptive()
                        : getRichText(text, isUser);

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
              },
              padding: const EdgeInsets.only(bottom: 10),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    )
                  ]),
              width: double.infinity,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: IntrinsicHeight(
                    child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: inputPannel())),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column inputPannel() {
    return Column(
      children: [
        SizedBox(
          height: 20,
          child: Center(
            child: buildHandle(),
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: buildInputTF(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Container buildHandle() {
    return Container(
      height: 10,
      width: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[400],
      ),
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
        prefixIcon: IntrinsicWidth(
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
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
                  child: const Icon(
                    Icons.list,
                    color: Colors.black,
                  )),
            ],
          ),
        ),
        hintText: "تایپ کنید",
        hintStyle: const TextStyle(
          color: Colors.black54,
        ),
        border: InputBorder.none,
        suffixIcon: FloatingActionButton(
          mini: true,
          onPressed: isFetchingCompletion || tffController.text.isEmpty
              ? null
              : () => processUserInput(tffController.text),
          // hoverColor: Colors.green,
          elevation: 0,
          hoverElevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(
            Icons.send,
            color: Colors.black,
            size: 22,
          ),
        ),
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
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
  }
}
