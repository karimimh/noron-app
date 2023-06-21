import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'tools.dart';

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

class ChatGPTCompletion {
  final String completion;

  const ChatGPTCompletion({required this.completion});

  factory ChatGPTCompletion.fromJson(Map<String, dynamic> json) {
    return ChatGPTCompletion(completion: json['result']);
  }
}

class _TextToolFormState extends State<TextToolForm> {
  final tffController = TextEditingController();
  late Future<ChatGPTCompletion> futureChatGPTCompletion;

  @override
  void initState() {
    super.initState();
    futureChatGPTCompletion =
        Future(() => const ChatGPTCompletion(completion: ""));
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

Future<ChatGPTCompletion> fetchChatGPTCompletion(
    apiKey, messages, temperature) async {
  print(jsonEncode(messages));
  String url = 'http://45.90.74.46:8000/chatgptcompletion/';
  final response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Token $apiKey'
      },
      body: jsonEncode(<String, String>{
        'messages': json.encode(messages),
        'temperature': '$temperature'
      }));

  if (response.statusCode == 200) {
    return ChatGPTCompletion.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)));
  } else {
    print(response.statusCode);
    print(response.body);
    throw Exception('Failed to load the chatgpt-completion');
  }
}
