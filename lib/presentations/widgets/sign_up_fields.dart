import 'package:edusurvey/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpFormFields extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final TextInputType? keyBoardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ToolbarOptions? toolbarOptions;

  SignUpFormFields({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.keyBoardType,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.readOnly = false,
    this.toolbarOptions,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyBoardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      textInputAction: textInputAction,
      style: const TextStyle(color: AllColors.textColor),

      toolbarOptions:
          toolbarOptions ??
          const ToolbarOptions(
            copy: true,
            cut: false,
            paste: false,
            selectAll: true,
          ),

      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.5,
          ), // Changed error border to white
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19),
          borderSide: const BorderSide(
            color: Colors.yellow,
            width: 2.0,
          ), // Yellow to highlight errors
        ),
        errorStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ), // White error text

        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color.fromARGB(255, 172, 160, 160).withOpacity(0.7),
        ),

        prefixIcon:
            prefixIcon != null
                ? IconTheme(
                  data: IconThemeData(
                    color: Colors.grey.shade300,
                  ), // Light gray for better visibility
                  child: prefixIcon!,
                )
                : null,

        suffixIcon:
            suffixIcon != null
                ? IconTheme(
                  data: IconThemeData(
                    color: Colors.grey.shade300,
                  ), // Light gray suffix icon
                  child: suffixIcon!,
                )
                : null,
      ),

      readOnly: readOnly,
      validator: validator,
      inputFormatters: inputFormatters,

      onTap:
          readOnly
              ? () {
                FocusScope.of(context).requestFocus(FocusNode());
              }
              : null,
    );
  }
}
