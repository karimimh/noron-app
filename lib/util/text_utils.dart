import 'package:flutter/material.dart';
import 'package:noron_front/util/my_code_highlighter.dart';
import 'highlighter_theme.dart';

String detectLanguage({required String string}) {
  if (string.isEmpty) {
    return 'fa';
  }
  String languageCodes = 'en';
  final RegExp persian = RegExp(r'^[\u0600-\u06FF]+');
  final RegExp english = RegExp(r'^[A-Za-z]+');
  if (persian.hasMatch(string)) {
    languageCodes = 'fa';
  } else if (english.hasMatch(string)) {
    languageCodes = 'en';
  }

  return languageCodes;
}

bool detectRTL({required String string}) {
  return detectLanguage(string: string) == "fa";
}

TextSpan highlightedBackTicks(String text) {
  List<String> parts = text.split('`');
  List<InlineSpan> spans = [];

  for (int i = 0; i < parts.length; i++) {
    if (i % 2 == 0) {
      spans.add(TextSpan(text: parts[i]));
    } else {
      bool isRTL = detectLanguage(string: parts[i]) == "fa";
      spans.add(WidgetSpan(
          child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xffE7E7ED),
                  borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: SelectableText(
                  parts[i],
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                ),
              ))));
    }
  }

  return TextSpan(children: spans);
}

SelectableText getRichText(String text, Color textColor, TextAlign textAlign) {
  final isRTL = detectRTL(string: text);

  RegExp regexp = RegExp(r"```([\s\S]*?)```");
  Iterable<Match> matches = regexp.allMatches(text);

  final List<InlineSpan> children = [];

  int currentIndex = 0;
  // print("matches.length = ${matches.length}");
  for (Match match in matches) {
    final matchString = match.group(1);
    final startIndex = match.start;
    final endIndex = match.end;

    if (startIndex > currentIndex) {
      children.add(highlightedBackTicks(
          text.substring(currentIndex, startIndex).trimRight()));
    }

    String delimitedText = matchString ?? "";
    children.add(WidgetSpan(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Builder(builder: (context) {
                final codeLanguageRegexp = RegExp(r"^\w+");
                final foundLanguage =
                    codeLanguageRegexp.hasMatch(delimitedText);
                String codeLanguage = '';
                String code = delimitedText;
                if (foundLanguage) {
                  codeLanguage = delimitedText.split('\n')[0];
                  code = code.substring(codeLanguage.length).trim();
                }
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: MyHighlightView(
                    code,
                    language: codeLanguage,
                    theme: myHighlighterTheme,
                    padding: const EdgeInsets.all(8),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ));

    currentIndex = endIndex;
  }

  if (currentIndex < text.length) {
    children.add(highlightedBackTicks(
        text.substring(currentIndex, text.length).trimRight()));
  }

  return SelectableText.rich(
    TextSpan(
      children: children,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
    ),
    textAlign: textAlign,
    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
  );
}

//SelectableText(
//   text,
//   textDirection:
//       isRTL ? TextDirection.rtl : TextDirection.ltr,
//   textAlign: isUser ? TextAlign.right : TextAlign.left,
//   style: TextStyle(fontSize: 16, color: textColor),
// )
