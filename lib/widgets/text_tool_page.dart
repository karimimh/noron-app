import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'dart:async';

import '../api/openai.dart';
import '../objects/chat.dart';

class TextToolPage extends StatefulWidget {
  final NoronAppData noron;
  final String initialToolText;

  const TextToolPage(
      {super.key, required this.noron, required this.initialToolText});

  @override
  State<TextToolPage> createState() => _TextToolPageState();
}

class _TextToolPageState extends State<TextToolPage> {
  final tffController = TextEditingController();
  late Future<ChatGPTCompletion> futureChatGPTCompletion;
  bool isFetchingCompletioon = false;

  @override
  void initState() {
    super.initState();
    tffController.text = widget.initialToolText;
    futureChatGPTCompletion =
        Future(() => const ChatGPTCompletion(completions: []));
  }

  @override
  void dispose() {
    tffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          children: [
            TextFormField(
              maxLength: 4000,
              minLines: 1,
              maxLines: 10,
              controller: tffController,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (tffController.text.isNotEmpty) {
                      final messages = [
                        {
                          "role": "system",
                          "content":
                              "Assistant is a helpful language model created by OpenAI"
                        },
                        {"role": "user", "content": tffController.text}
                      ];
                      futureChatGPTCompletion = fetchChatGPTCompletion(
                          user: widget.noron.user,
                          messages: messages,
                          temperature: 0.7);
                      futureChatGPTCompletion.whenComplete(() {
                        setState(() {
                          isFetchingCompletioon = false;
                        });
                      });
                      isFetchingCompletioon = true;
                    }
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("اجرا"),
                )),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
              future: futureChatGPTCompletion,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.firstChoice.isNotEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.black12,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: SelectableText(
                      snapshot.data!.firstChoice,
                      textAlign: TextAlign.justify,
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
                } else if (isFetchingCompletioon) {
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16.0),
                    child: const CircularProgressIndicator.adaptive(),
                  );
                }
                return Container();
              },
            )
          ],
        ));
  }
}
