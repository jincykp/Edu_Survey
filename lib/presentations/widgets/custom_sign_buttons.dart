import 'package:edusurvey/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final EdgeInsetsGeometry? padding; // New parameter
  final double textSize; // New parameter
  final double borderRadius; // New parameter

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.padding, // Optional parameter
    this.textSize = 18, // Default to original size
    this.borderRadius = 20, // Default to original radius
  });

  @override
  Widget build(BuildContext context) {
    print("Button build called. isLoading: $isLoading, text: $text");
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isLoading
                ? AllColors.primaryColor.withOpacity(0.7)
                : AllColors.primaryColor,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child:
          isLoading
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: textSize, // Scale the spinner according to text size
                    height: textSize,
                    child: const CircularProgressIndicator(
                      color: AllColors.textColor,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: AllColors.textColor,
                    ),
                  ),
                ],
              )
              : Text(
                text,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                  color: AllColors.textColor,
                ),
              ),
    );
  }
}
