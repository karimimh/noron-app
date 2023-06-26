import 'package:flutter/material.dart';
import 'dart:async';

import '../api/openai.dart';
import '../objects/chat.dart';
import '../objects/tools.dart';

class TextToolForm extends StatefulWidget {
  final String apiKey;
  final CommandString command;
  final bool needsTextFormField;
  final String textFormFieldLabelText;
  final int textFormFieldMinLines;
  final String buttonText;

  const TextToolForm({
    super.key,
    required this.apiKey,
    required this.command,
    required this.needsTextFormField,
    required this.textFormFieldLabelText,
    required this.textFormFieldMinLines,
    required this.buttonText,
  });

  @override
  State<TextToolForm> createState() => _TextToolFormState();
}

class _TextToolFormState extends State<TextToolForm> {
  final tffController = TextEditingController();
  late Future<ChatGPTCompletion> futureChatGPTCompletion;

  @override
  void initState() {
    super.initState();
    futureChatGPTCompletion =
        Future(() => const ChatGPTCompletion(completion: "", error: ""));
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text.rich(
                widget.command.getTextSpan(setState),
              ),
              if (widget.needsTextFormField)
                const SizedBox(
                  height: 10,
                ),
              if (widget.needsTextFormField)
                TextFormField(
                  maxLength: 4000,
                  minLines: widget.textFormFieldMinLines,
                  maxLines: widget.textFormFieldMinLines,
                  controller: tffController,
                  decoration: InputDecoration(
                      labelText: widget.textFormFieldLabelText,
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
                    String userMessage =
                        '${widget.command.getCurrentChoice()} ${widget.needsTextFormField ? "\n####\n${tffController.text}\n####" : ""}';
                    List<Map<String, dynamic>> messages = [
                      {
                        "role": "system",
                        "content":
                            "Assisstant is a helpful language model created by OpenAI"
                      },
                      {"role": "user", "content": userMessage}
                    ];
                    try {
                      setState(() {
                        futureChatGPTCompletion = fetchChatGPTCompletion(
                            widget.apiKey, messages, 0.7);
                      });
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(widget.buttonText),
                  )),
              const SizedBox(
                height: 20,
              ),
              FutureBuilder(
                future: futureChatGPTCompletion,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.black12,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        snapshot.data!.completion,
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
