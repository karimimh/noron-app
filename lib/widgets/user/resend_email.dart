import 'package:flutter/material.dart';
import 'package:noron_front/objects/noron.dart';
import 'package:noron_front/widgets/user/login_page.dart';
import '../../api/user_api.dart';

class ResendEmailPage extends StatefulWidget {
  final NoronAppData noron;
  const ResendEmailPage({super.key, required this.noron});

  @override
  State<ResendEmailPage> createState() => _ResendEmailPageState();
}

class _ResendEmailPageState extends State<ResendEmailPage> {
  bool isSendingEmail = false;
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
                "ارسال مجدد ایمیل فعالسازی",
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
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => isSendingEmail ? Colors.black45 : Colors.black),
              ),
              onPressed: isSendingEmail
                  ? null
                  : () {
                      isSendingEmail = true;
                      resendMail(email: emailTFController.text).then((value) {
                        setState(() {
                          isSendingEmail = false;
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) {
                              return LoginPage(noron: widget.noron);
                            },
                          ));
                        });
                      }).onError((error, stackTrace) {
                        setState(() {
                          isSendingEmail = false;
                        });
                      });
                    },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "ارسال",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            TextButton(
                onPressed: isSendingEmail
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
                  if (isSendingEmail) {
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
