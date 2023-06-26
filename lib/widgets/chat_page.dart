import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/widgets/text_tools_list.dart';

import '../api/openai.dart';

class ChatPage extends StatefulWidget {
  final NoronAppData noron;

  const ChatPage({super.key, required this.noron});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final tffController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void dispose() {
    tffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: ListView.builder(
              controller: scrollController,
              itemCount: widget.noron.chat.length(),
              itemBuilder: (context, index) {
                final message = widget.noron.chat.messages[index];
                final text = message.text;
                final isUser = message.isUser;
                final isFetching = message.isFetching;
                final isRTL = message.isRTL;

                final bubbleType =
                    isUser ? BubbleType.sendBubble : BubbleType.receiverBubble;
                final bubbleAlignment =
                    isUser ? Alignment.centerRight : Alignment.centerLeft;
                final bubbleColor =
                    isUser ? Colors.blue[400] : const Color(0xffE7E7ED);
                final textColor = isUser ? Colors.white : Colors.black;

                final chatBubbleChild = isFetching
                    ? const CircularProgressIndicator.adaptive()
                    : SelectableText(
                        text,
                        textDirection:
                            isRTL ? TextDirection.rtl : TextDirection.ltr,
                        textAlign: isUser ? TextAlign.right : TextAlign.left,
                        style: TextStyle(fontSize: 16, color: textColor),
                      );

                return ChatBubble(
                  clipper: ChatBubbleClipper4(type: bubbleType),
                  alignment: bubbleAlignment,
                  margin: const EdgeInsets.only(top: 20, right: 10, left: 10),
                  backGroundColor: bubbleColor,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
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
              // margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.only(left: 10, right: 0),
              width: double.infinity,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: 10,
                      autofocus: false,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      decoration: InputDecoration(
                          prefixIcon: GestureDetector(
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
                              child: const Icon(Icons.list)),
                          hintText: widget.noron.isRTL()
                              ? "تایپ کنید..."
                              : "type here ...",
                          hintStyle: const TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                      controller: tffController,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        if (tffController.text.isNotEmpty &&
                            !widget.noron.chat.last().isFetching) {
                          widget.noron.chat.add(
                              tffController.text, true, widget.noron.isRTL());
                          widget.noron.chat
                              .add("", false, widget.noron.isRTL());
                          widget.noron.chat.last().isFetching = true;
                          scrollTheChat();
                          fetchChatResponse(
                            chat: widget.noron.chat,
                            token: widget.noron.user.token,
                            onCompletion: (chatGPTCompletion) {
                              setState(() {
                                widget.noron.chat.last().text =
                                    chatGPTCompletion.completion;
                                widget.noron.chat.last().isFetching = false;
                                scrollTheChat();
                              });
                            },
                            onError: (gptReponse) {
                              setState(() {
                                widget.noron.chat.last().isFetching = false;
                                widget.noron.chat.messages.removeLast();
                                widget.noron.chat.messages.removeLast();
                              });
                            },
                          );
                          tffController.clear();
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

  void scrollTheChat() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
  }
}
