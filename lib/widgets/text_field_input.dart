import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {
  final String hintText;
  final bool isPass;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const TextFieldInput(
      {Key? key,
      required this.hintText,
      required this.controller,
      this.isPass = false,
      required this.keyboardType})
      : super(key: key);

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        suffixIcon: widget.isPass
            ? IconButton(
                splashColor: Colors.transparent,
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  setState(() {
                    if (isVisible == false) {
                      isVisible = true;
                    } else {
                      isVisible = false;
                    }
                  });
                },
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                splashRadius: 1,
              )
            : const SizedBox.shrink(),
        hintText: widget.hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      obscureText: widget.isPass && !isVisible,
      keyboardType: widget.keyboardType,
    );
  }
}
