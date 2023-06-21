import 'package:flutter/material.dart';

class ChangeableString {
  String string;
  ChangeableString(this.string);
}

class DropdownString {
  final List<String> choices;
  int currentIndex = 0;
  DropdownString(this.choices);
}

class CommandString {
  final List<Object> strings;
  final bool needsTextFormField;
  final String textFormFieldLabelText;
  final int textFormFieldMinLines;
  final String buttonText;

  CommandString(this.strings, this.needsTextFormField,
      this.textFormFieldLabelText, this.textFormFieldMinLines, this.buttonText);

  String getFirstChoice() {
    String result = "";
    for (var obj in strings) {
      if (obj is String) {
        result += obj;
      } else if (obj is DropdownString) {
        result += obj.choices[0];
      } else {
        result += obj.toString();
      }
    }
    return result;
  }

  String getCurrentChoice() {
    String result = "";
    for (var obj in strings) {
      if (obj is String) {
        result += obj;
      } else if (obj is DropdownString) {
        result += obj.choices[obj.currentIndex];
      } else {
        result += obj.toString();
      }
    }
    return result;
  }

  List<DropdownString> getDropDownStrings() {
    List<DropdownString> result = [];
    for (var string in strings) {
      if (string is DropdownString) {
        result.add(string);
      }
    }
    return result;
  }

  TextSpan getTextSpan(Function setState) {
    List<DropdownString> dropdownStrings = getDropDownStrings();
    int N = dropdownStrings.length;

    List<InlineSpan> children = [];

    int currentDDS = 0;
    for (var i = 0; i < strings.length; i++) {
      final element = strings[i];
      if (element is String) {
        children
            .add(TextSpan(text: element, style: const TextStyle(fontSize: 18)));
      } else if (element is DropdownString) {
        DropdownString elementToAdd = dropdownStrings[N - 1 - currentDDS];
        currentDDS += 1;
        children.add(WidgetSpan(
            child: PopupMenuButton(
          child: Text(
            elementToAdd.choices[elementToAdd.currentIndex],
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 18,
            ),
          ),
          itemBuilder: (context) {
            var menuItems = [];
            for (var j = 0; j < elementToAdd.choices.length; j++) {
              menuItems.add(PopupMenuItem<int>(
                value: j,
                child: Text(elementToAdd.choices[j]),
                onTap: () {
                  setState(() {
                    elementToAdd.currentIndex = j;
                  });
                },
              ));
            }
            return <PopupMenuEntry<int>>[...menuItems];
          },
        )));
      }
    }
    return TextSpan(children: children);
  }
}

class TextTool {
  final String title;
  final IconData icon;
  final List<CommandString> items;

  TextTool(this.title, this.icon, this.items);
}

List<TextTool> textTools = [
  TextTool("تشریح", Icons.school_outlined, [
    CommandString(["هوش مصنوعی رو به زبان ساده توضیح بده"], true,
        "متن خود را اینجا وارد کنید.", 8, "▶︎"),
  ]),
  TextTool("پیشنهاد ایده", Icons.lightbulb_outline, [
    CommandString(
        ["ایده‌های پژوهشی برای دوره دکترا در زمینه لیزرهای فوتونیک بده"],
        true,
        "متن خود را اینجا وارد کنید.",
        8,
        "▶︎"),
    CommandString(
        ["ایده‌های نو برای کسب درامد برای مهندس نرم‌افزار پیشنهاد بده"],
        true,
        "متن خود را اینجا وارد کنید.",
        8,
        "▶︎"),
  ]),
  TextTool("خلاصه‌سازی", Icons.summarize_outlined, [
    CommandString([
      "متن زیر را ",
      DropdownString([
        "در یک جمله ",
        "در دو جمله ",
        "در سه جمله ",
        "در چهار جمله ",
        "در پنج جمله ",
        " ",
      ]),
      "خلاصه کن.",
    ], true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
    CommandString([
      "محتوای صفحه تارنمای زیر رو ",
      DropdownString([
        "در یک جمله ",
        "در دو جمله ",
        "در سه جمله ",
        "در چهار جمله ",
        "در پنج جمله ",
        " "
      ]),
      "خلاصه کن."
    ], true, "نشانی صفحه تارنمای مورد نظر را اینجا وارد کنید.", 2, "▶︎"),
  ]),
  TextTool("ترجمه", Icons.translate, [
    CommandString([
      "متن زیر رو ",
      DropdownString([
        "به انگلیسی ",
        "به فارسی ",
        "به عربی ",
      ]),
      "ترجمه کن."
    ], true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
    CommandString([
      "متن زیر رو ",
      DropdownString([
        "به انگلیسی ",
        "به فارسی ",
        "به عربی ",
      ]),
      "ترجمه کرده، سپس ",
      DropdownString([
        "در یک جمله ",
        "در دو جمله ",
        "در سه جمله ",
        "در چهار جمله ",
        "در پنج جمله ",
        " "
      ]),
      "خلاصه کن."
    ], true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
  ]),
  TextTool("تحقیق و مقاله نویسی", Icons.article_outlined, [
    CommandString([
      "فرض کن تو یک دانش‌آموز دوره دبستان هستی. یک تحقیق در خصوص خطرناک‌ترین حیوانات دریایی بنویس"
    ], true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
    CommandString(["یک مقاله در خصوص آینده هوش مصنوعی در زمینه آموزش بنویس"],
        true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
    CommandString(["یک تحقیق در خصوص مسائل حل نشده در حوزه نظریه اعداد بنویس."],
        true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
  ]),
  TextTool("انتخاب عنوان", Icons.title, [
    CommandString(["۵ عنوان برای متن زیر پیشنهاد کن. "], true,
        "متن خود را اینجا وارد کنید.", 8, "▶︎"),
  ]),
  TextTool("رایانامه نویسی", Icons.email_outlined, [
    CommandString([
      "فرض کن تو یک دانشجوی دوره کارشناسی در رشته مهندسی کامپیوتر هستی. یک ایمیل برای استاد کامرانی بنویس که از او درخواست کنی مهلت تمارین را یک هفته به عقب بیاندازد. از این بهانه که این هفته آزمون دیگری داری استفاده کن."
    ], true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
  ]),
  TextTool("داستان‌سرایی", Icons.edit_note, [
    CommandString([
      "یک داستان ",
      DropdownString([
        "طنز ",
        "جنایی",
        "تخیلی ",
        "علمی ",
        "کوتاه ",
        " ",
      ]),
      "با حداکثر ",
      DropdownString([
        "۱۰۰ کلمه ",
        "۲۵۰ کلمه ",
        "۵۰۰ کلمه ",
        "۱۰ جمله",
        "۲۰ جمله",
      ]),
      " بساز",
    ], false, "", 8, "▶︎"),
    CommandString(["یک قصه کودکانه برای خواب بچه‌ها بگو"], false, "", 8, "▶︎"),
    CommandString([
      "یک داستان ",
      DropdownString([
        "طنز ",
        "جنایی",
        "تخیلی ",
        "علمی ",
        "کوتاه ",
        " ",
      ]),
      "با حداکثر ",
      DropdownString([
        "۱۰۰ کلمه ",
        "۲۵۰ کلمه ",
        "۵۰۰ کلمه ",
        "۱۰ جمله",
        "۲۰ جمله",
      ]),
      " با موضوع زیر بساز",
    ], true, "موضوع", 1, "▶︎"),
  ]),
  TextTool("شعرگویی", Icons.history_edu, [
    CommandString(["یک شعر کوتاه در مورد ربات‌ها بگو"], true,
        "متن خود را اینجا وارد کنید.", 8, "▶︎"),
    CommandString(["۱۰بیت شعر از اشعار حافظ انتخاب کن"], false, "", 8, "▶︎"),
  ]),
  TextTool("پست نویسی", Icons.post_add, [
    CommandString(["یک پست در خصوص میوه سیب برای شبکه اجتماعی توییتر بنویس"],
        true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
  ]),
  TextTool("ساخت کوییز", Icons.quiz_outlined, [
    CommandString(["یک کوییز در خصوص موضوع زبان برنامه‌نویسی پایتون بساز"],
        true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
  ]),
  TextTool("حل معما", Icons.check, [
    CommandString([
      "معمای زیر رو حل کن: در یک اتاق ۱۰۰ نفره به طور متوسط چند نفر روز تولدشان با من یکسان است؟"
    ], true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
  ]),
  TextTool("برنامه‌ریزی", Icons.checklist, [
    CommandString(["یک برنامه غذایی برای لاغر شدن در طول یکماه طراحی کن."],
        true, "متن خود را اینجا وارد کنید.", 8, "▶︎"),
  ]),
  TextTool("تصحیح متن", Icons.spellcheck, [
    CommandString(["غلط‌های املایی متن زیر را اصلاح کن."], true,
        "متن خود را اینجا وارد کنید.", 8, "▶︎"),
    CommandString(["متن زیر را از لحاظ نگارشی اصلاح کن"], true,
        "متن خود را اینجا وارد کنید.", 8, "▶︎"),
  ]),
];
