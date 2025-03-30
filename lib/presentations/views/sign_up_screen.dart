import 'package:edusurvey/presentations/views/home_screen.dart';
import 'package:edusurvey/presentations/widgets/custom_sign_buttons.dart';
import 'package:edusurvey/presentations/widgets/validations.dart';
import 'package:edusurvey/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:edusurvey/core/theme/colors.dart';
import 'package:edusurvey/core/theme/text_styles.dart';
import 'package:edusurvey/presentations/widgets/sign_up_fields.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers for form fields
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AllColors.primaryColor,
              AllColors.gradientSecond,
              AllColors.gradientThird,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school,
                    color: AllColors.textColor,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  const Text('Create Account', style: TextStyles.titleText),
                  const SizedBox(height: 20),

                  // Full Name Field
                  SignUpFormFields(
                    controller: nameController,
                    hintText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    validator: SignUpValidator.validateName,
                  ),
                  const SizedBox(height: 10),

                  // Email Field
                  SignUpFormFields(
                    controller: emailController,
                    hintText: 'Email',
                    keyBoardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email),
                    validator: SignUpValidator.validateEmail,
                  ),
                  const SizedBox(height: 10),

                  // Password Field
                  SignUpFormFields(
                    controller: passwordController,
                    hintText: 'Password',
                    keyBoardType: TextInputType.visiblePassword,
                    inputFormatters: [LengthLimitingTextInputFormatter(6)],
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: const Icon(Icons.visibility),
                    validator: SignUpValidator.validatePassword,
                  ),
                  const SizedBox(height: 10),

                  // Confirm Password Field
                  SignUpFormFields(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    keyBoardType: TextInputType.visiblePassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: const Icon(Icons.visibility),
                    inputFormatters: [LengthLimitingTextInputFormatter(6)],
                    validator:
                        (value) => SignUpValidator.validateConfirmPassword(
                          value,
                          passwordController.text,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return CustomButton(
                          text:
                              userProvider.isLoading
                                  ? 'Signing up...'
                                  : 'Sign Up',
                          isLoading: userProvider.isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Call Provider method for sign up
                              await userProvider.signUp(
                                nameController.text.trim(),
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );

                              // Only proceed if sign-up completed successfully
                              if (!userProvider.isLoading && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: AllColors.successColor,
                                    content: Text('Sign up successful!'),
                                  ),
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Already have an account? Login
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to login screen
                    },
                    child: const Text(
                      'Already have an account? Log in',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
