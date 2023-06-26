// import 'package:flutter/material.dart';
// import 'package:noron_front/models/noron.dart';

// import '../models/user.dart';

// class MyDrawer extends StatefulWidget {
//   final NoronAppData noron;
//   const MyDrawer({super.key, required this.noron});

//   @override
//   State<StatefulWidget> createState() {
//     return _MyDrawerState();
//   }
// }

// class _MyDrawerState extends State<MyDrawer> {
//   final nameTFController = TextEditingController();
//   final emailTFController = TextEditingController();
//   final passwordTFController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: ListView(
//         // Important: Remove any padding from the ListView.
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Color.fromRGBO(240, 240, 240, 1.0),
//               ),
//               child: Builder(builder: (context) {
//                 return TextButton(onPressed: () {
//                   Navigator.of(context).pop();
//                   showDialog(
//                       context: context,
//                       builder: (context) => _loginDialog(context));
//                 }, child: Builder(builder: (context) {
//                   if (widget.noron.user.email.isNotEmpty) {
//                     return Text(widget.noron.user.email);
//                   } else {
//                     return const Text("ورود");
//                   }
//                 }));
//               })),
//           ListTile(
//             title: const Text('Item 1'),
//             onTap: () {
//               // Update the state of the app.
//               // ...
//             },
//           ),
//           ListTile(
//             title: const Text('Item 2'),
//             onTap: () {
//               // Update the state of the app.
//               // ...
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   AlertDialog _loginDialog(BuildContext context) {
//     return AlertDialog(
//       title: const Text('ورود'),
//       content: SizedBox(
//         height: 250,
//         child: Column(
//           children: [
//             TextField(
//               autofocus: true,
//               keyboardType: TextInputType.name,
//               maxLength: 100,
//               minLines: 1,
//               maxLines: 1,
//               controller: nameTFController,
//               textDirection: TextDirection.ltr,
//               decoration: InputDecoration(
//                   labelText: "نام",
//                   filled: true,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5))),
//             ),
//             TextField(
//               keyboardType: TextInputType.emailAddress,
//               maxLength: 100,
//               minLines: 1,
//               maxLines: 1,
//               controller: emailTFController,
//               textDirection: TextDirection.ltr,
//               decoration: InputDecoration(
//                   labelText: "ایمیل",
//                   filled: true,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5))),
//             ),
//             TextField(
//               keyboardType: TextInputType.visiblePassword,
//               maxLength: 100,
//               minLines: 1,
//               maxLines: 1,
//               controller: passwordTFController,
//               textDirection: TextDirection.ltr,
//               decoration: InputDecoration(
//                   labelText: "رمز عبور",
//                   filled: true,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5))),
//             ),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//             try {
//               login(nameTFController.text, emailTFController.text,
//                       passwordTFController.text)
//                   .then((value) {
//                 widget.noron.user.name = value.name;
//                 widget.noron.user.email = value.email;
//                 widget.noron.user.token = value.token;
//                 widget.noron.save();
//               });
//             } catch (e) {
//               print("Failed signin");
//             }
//           },
//           child: const Text(
//             'تأیید',
//             style: TextStyle(color: Colors.green),
//           ),
//         ),
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: const Text(
//             'لغو',
//             style: TextStyle(color: Colors.red),
//           ),
//         ),
//       ],
//       actionsAlignment: MainAxisAlignment.spaceEvenly,
//     );
//   }
// }
