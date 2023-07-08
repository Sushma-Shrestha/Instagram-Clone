// import 'package:flutter/material.dart';
// import 'package:instagram_clone/resources/auth_methods.dart';
// import 'package:instagram_clone/screens/login_screen.dart';
// import 'package:instagram_clone/utils/colors.dart';
// import 'package:instagram_clone/utils/utils.dart';

// class LogoutButton extends StatefulWidget {
//   const LogoutButton({Key? key}) : super(key: key);

//   @override
//   State<LogoutButton> createState() => _LogoutButtonState();
// }

// bool isLoading = false;

// class _LogoutButtonState extends State<LogoutButton> {
//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       style: ButtonStyle(
//         padding: MaterialStateProperty.all(
//           const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//         ),
//         backgroundColor: MaterialStateProperty.all(blueColor),
//       ),
//       onPressed: () async {
//         setState(() {
//           isLoading = true;
//         });
//         String res = await AuthMethods().logOutUser();
//         if (res == 'Success') {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => const LoginScreen(),
//             ),
//           );
//         } else {
//           showSnackBar(res, context);
//         }
//         setState(() {
//           isLoading = false;
//         });
//       },
//       child: isLoading
//           ? const CircularProgressIndicator(
//               color: primaryColor,
//             )
//           : const Text(
//               'Log Out',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//     );
//   }
// }
