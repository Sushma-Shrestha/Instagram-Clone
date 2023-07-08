import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/utils/global_variables.dart';

pickImage(ImageSource imageSource) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? _file = await imagePicker.pickImage(source: imageSource);

  if (_file != null) {
    return await _file.readAsBytes();
  }
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.maybeOf(context)!.showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 1500),
      dismissDirection: DismissDirection.up,
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      margin: MediaQuery.of(context).size.width > webScreenSize
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2)
          : const EdgeInsets.symmetric(horizontal: 15),
      content: Text(
        content,
        style: TextStyle(fontSize: 17, color: Colors.grey[700]),
      ),
    ),
  );
}
