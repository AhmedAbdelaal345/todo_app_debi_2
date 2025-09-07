import 'package:flutter/material.dart';

class TextFiledWidget extends StatelessWidget {
  TextFiledWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.contentPadding,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final EdgeInsets? contentPadding;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    // Use TextFormField instead of TextField to support validation
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.grey),
      cursorColor: Colors.grey,
      decoration: InputDecoration(
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        filled: true,
        fillColor: const Color(0xffF3F3F5),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xffF3F3F5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xffF3F3F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }
}