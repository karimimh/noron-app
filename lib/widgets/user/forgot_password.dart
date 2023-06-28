import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/widgets/user/login_page.dart';

import '../../api/user_api.dart';

class ForgotPasswordPage extends StatefulWidget {
  final NoronAppData noron;
  const ForgotPasswordPage({super.key, required this.noron});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool isResettingPassword = false;
  final emailTFController = TextEditingController();
  String errorString = "";

  @override
  void dispose() {
    emailTFController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "فراموشی رمز عبور",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28),
              ),
            ),
            _textFieldTemplate(
              keyboardType: TextInputType.emailAddress,
              controller: emailTFController,
              labelText: "ایمیل",
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateColor.resolveWith((states) => Colors.black),
              ),
              onPressed: isResettingPassword
                  ? null
                  : () {
                      setState(() {
                        isResettingPassword = true;
                      });
                      resetPassword(email: emailTFController.text)
                          .then((value) {
                        setState(() {
                          isResettingPassword = false;
                        });
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) {
                            return LoginPage(noron: widget.noron);
                          },
                        ));
                      }).onError((error, stackTrace) {
                        setState(() {
                          isResettingPassword = false;
                        });
                      });
                    },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "ارسال ایمیل",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            TextButton(
                onPressed: isResettingPassword
                    ? null
                    : () {
                        //go to login page:
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) {
                            return LoginPage(noron: widget.noron);
                          },
                        ));
                      },
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "ورود",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Builder(
                builder: (context) {
                  if (isResettingPassword) {
                    return const CircularProgressIndicator.adaptive();
                  }
                  return Text(
                    errorString,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

TextField _textFieldTemplate({keyboardType, controller, labelText}) {
  return TextField(
    autofocus: false,
    keyboardType: keyboardType,
    maxLength: 100,
    buildCounter: (context,
        {required currentLength, required isFocused, maxLength}) {
      return Container();
    },
    minLines: 1,
    maxLines: 1,
    controller: controller,
    textDirection: TextDirection.ltr,
    decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
  );
}
