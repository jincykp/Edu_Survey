import 'package:edusurvey/presentations/views/forgot_password_screen.dart';
import 'package:edusurvey/presentations/views/home_screen.dart';
import 'package:edusurvey/presentations/views/sign_up_screen.dart';
import 'package:edusurvey/presentations/widgets/custom_sign_buttons.dart';
import 'package:edusurvey/presentations/widgets/validations.dart';
import 'package:edusurvey/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:edusurvey/core/theme/colors.dart';
import 'package:edusurvey/core/theme/text_styles.dart';
import 'package:edusurvey/presentations/widgets/sign_up_fields.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school,
                      color: AllColors.textColor,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text('Edu Survey', style: TextStyles.titleText),
                    const SizedBox(height: 30),

                    SignUpFormFields(
                      controller: emailController,
                      hintText: 'Email',
                      keyBoardType: TextInputType.emailAddress,
                      validator: SignUpValidator.validateEmail,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    const SizedBox(height: 15),
                    SignUpFormFields(
                      controller: passwordController,
                      hintText: 'Password',
                      inputFormatters: [LengthLimitingTextInputFormatter(6)],
                      keyBoardType: TextInputType.visiblePassword,
                      prefixIcon: const Icon(Icons.lock),
                      validator: SignUpValidator.validatePassword,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.visibility_off),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text:
                                userProvider.isLoading
                                    ? 'Signing in...'
                                    : 'Login',
                            isLoading: userProvider.isLoading,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await userProvider.signIn(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );

                                if (success && context.mounted) {
                                  // Navigate to Home Screen on successful login
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  );
                                } else if (context.mounted) {
                                  // Show error message using ScaffoldMessenger
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        userProvider.errorMessage ??
                                            "Invalid email or password",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don’t have an account?',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
