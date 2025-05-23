import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/widgets/startup_page.dart';
import 'package:noron_front/widgets/user/forgot_password.dart';
import 'package:noron_front/widgets/user/signup_page.dart';
import '../../api/user_api.dart';

import 'resend_email.dart';

class LoginPage extends StatefulWidget {
  final NoronAppData noron;
  const LoginPage({super.key, required this.noron});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoggingIn = false;
  final emailTFController = TextEditingController();
  final passwordTFController = TextEditingController();
  String errorString = "";

  @override
  void dispose() {
    passwordTFController.dispose();
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
                "ورود",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28),
              ),
            ),
            _textFieldTemplate(
              keyboardType: TextInputType.emailAddress,
              controller: emailTFController,
              labelText: "ایمیل",
            ),
            _textFieldTemplate(
              keyboardType: TextInputType.visiblePassword,
              controller: passwordTFController,
              labelText: "رمز عبور",
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => isLoggingIn ? Colors.black45 : Colors.black),
              ),
              onPressed: isLoggingIn
                  ? null
                  : () {
                      login();
                    },
              child: Builder(builder: (context) {
                return const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "ورود",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }),
            ),
            TextButton(
                onPressed: isLoggingIn
                    ? null
                    : () {
                        //go to signup page:
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) {
                            return SignUpPage(noron: widget.noron);
                          },
                        ));
                      },
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "ثبت نام",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                )),
            TextButton(
                onPressed: isLoggingIn
                    ? null
                    : () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) {
                            return ForgotPasswordPage(noron: widget.noron);
                          },
                        ));
                      },
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "فراموشی رمز عبور",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                )),
            TextButton(
                onPressed: isLoggingIn
                    ? null
                    : () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) {
                            return ResendEmailPage(noron: widget.noron);
                          },
                        ));
                      },
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "ارسال مجدد ایمیل فعال‌سازی",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Builder(
                builder: (context) {
                  if (isLoggingIn) {
                    return const CircularProgressIndicator.adaptive();
                  }
                  return Text(
                    errorString,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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

  void login() {
    if (emailTFController.text.isEmpty || passwordTFController.text.isEmpty) {
      setState(() {
        errorString = "ایمیل و رمز عبور باید وارد شود.";
      });
      return;
    }

    setState(() {
      isLoggingIn = true;
      errorString = "";
    });

    createToken(
            email: emailTFController.text, password: passwordTFController.text)
        .then((value) {
      widget.noron.user.email = emailTFController.text;
      widget.noron.user.token = value;
      widget.noron.save();

      setState(() {
        isLoggingIn = false;
        // login successful. open the home page now:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return StartupPage(noron: widget.noron);
          },
        ));
      });
    }).onError((error, stackTrace) {
      setState(() {
        isLoggingIn = false;
        errorString = error.toString();
      });
    });
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
