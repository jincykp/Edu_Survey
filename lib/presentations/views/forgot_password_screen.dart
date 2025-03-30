import 'package:edusurvey/core/theme/colors.dart';
import 'package:edusurvey/core/theme/text_styles.dart';
import 'package:edusurvey/data/model/user_model.dart';
import 'package:edusurvey/presentations/views/login_screen.dart';
import 'package:edusurvey/presentations/widgets/custom_sign_buttons.dart';
import 'package:edusurvey/presentations/widgets/sign_up_fields.dart';
import 'package:edusurvey/presentations/widgets/validations.dart';
import 'package:edusurvey/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isEmailVerified = false;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  UserModel? foundUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AllColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                      Icons.lock_reset,
                      color: AllColors.textColor,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text('Reset Password', style: TextStyles.titleText),
                    const SizedBox(height: 20),

                    if (!isEmailVerified) ...[
                      // Step 1: Find account by email
                      const Text(
                        'Enter your email address to find your account',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      SignUpFormFields(
                        controller: emailController,
                        hintText: 'Email',
                        keyBoardType: TextInputType.emailAddress,
                        validator: SignUpValidator.validateEmail,
                        prefixIcon: const Icon(Icons.email),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: isLoading ? 'Verifying...' : 'Find Account',
                          isLoading: isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });

                              // Use the existing repository method through the provider
                              final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false,
                              );

                              try {
                                // Try to sign in with a dummy password to check if email exists
                                // We only care if the user exists, not if login succeeds
                                final dummyPassword =
                                    "dummy_password_for_check";
                                await userProvider.signIn(
                                  emailController.text.trim(),
                                  dummyPassword,
                                );

                                // Get user directly from repository
                                foundUser = await userProvider.getUserByEmail(
                                  emailController.text.trim(),
                                );

                                setState(() {
                                  isLoading = false;
                                  if (foundUser != null) {
                                    isEmailVerified = true;
                                  } else {
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No account found with this email!',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                });
                              } catch (e) {
                                setState(() {
                                  isLoading = false;
                                });

                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ] else ...[
                      // Step 2: Update password
                      Text(
                        'Create a new password for ${foundUser?.email}',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      SignUpFormFields(
                        controller: newPasswordController,
                        hintText: 'New Password',
                        inputFormatters: [LengthLimitingTextInputFormatter(6)],
                        keyBoardType: TextInputType.visiblePassword,
                        prefixIcon: const Icon(Icons.lock),
                        validator: SignUpValidator.validatePassword,
                        // obscureText: obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 15),

                      SignUpFormFields(
                        controller: confirmPasswordController,
                        hintText: 'Confirm New Password',
                        inputFormatters: [LengthLimitingTextInputFormatter(6)],
                        keyBoardType: TextInputType.visiblePassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        //   obscureText: obscureConfirmPassword,
                        validator: (value) {
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: isLoading ? 'Updating...' : 'Reset Password',
                          isLoading: isLoading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });

                              // Use the existing updatePassword method
                              final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false,
                              );

                              final success = await userProvider.updatePassword(
                                emailController.text.trim(),
                                newPasswordController.text.trim(),
                              );

                              setState(() {
                                isLoading = false;
                              });

                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password updated successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Navigate back to login screen
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to update password. Please try again.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
