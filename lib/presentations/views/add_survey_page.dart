import 'package:edusurvey/core/theme/colors.dart';
import 'package:edusurvey/presentations/widgets/custom_sign_buttons.dart';
import 'package:edusurvey/view_models/survey_provider.dart';
import 'package:edusurvey/view_models/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSurveyPage extends StatefulWidget {
  const AddSurveyPage({Key? key}) : super(key: key);

  @override
  _AddSurveyPageState createState() => _AddSurveyPageState();
}

class _AddSurveyPageState extends State<AddSurveyPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SurveyFormProvider(),
      child: Builder(
        builder: (context) {
          // Initialize the provider after it's created
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );
            final surveyProvider = Provider.of<SurveyFormProvider>(
              context,
              listen: false,
            );
            surveyProvider.initializeForm(userProvider.currentUser?.name);
          });

          return Consumer<SurveyFormProvider>(
            builder: (context, surveyProvider, _) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text(
                    'Add New Survey',
                    style: TextStyle(color: Colors.black87),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 1,
                  iconTheme: const IconThemeData(color: Colors.black87),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Survey Name
                          _buildFieldLabel('Survey Name'),
                          _buildTextField(
                            hintText: 'Enter survey name',
                            value: surveyProvider.surveyName,
                            onChanged:
                                (value) => surveyProvider.setSurveyName(value),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a survey name';
                              }
                              return null;
                            },
                          ),

                          // Reference Number (non-editable)
                          _buildFieldLabel('Reference Number'),
                          _buildReadOnlyField(surveyProvider.referenceNumber),

                          // Description
                          _buildFieldLabel('Detailed Description'),
                          _buildTextField(
                            hintText: 'Enter detailed description',
                            value: surveyProvider.description,
                            onChanged:
                                (value) => surveyProvider.setDescription(value),
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),

                          // Date of Commencement
                          _buildFieldLabel('Date of Commencement'),
                          _buildDateField(
                            context: context,
                            selectedDate: surveyProvider.commencementDate,
                            onTap:
                                () => _selectDate(
                                  context,
                                  surveyProvider.commencementDate,
                                  (date) =>
                                      surveyProvider.setCommencementDate(date),
                                ),
                            formattedDate: surveyProvider.formatDate(
                              surveyProvider.commencementDate,
                            ),
                          ),

                          // Due Date
                          _buildFieldLabel('Due Date'),
                          _buildDateField(
                            context: context,
                            selectedDate: surveyProvider.dueDate,
                            onTap:
                                () => _selectDate(
                                  context,
                                  surveyProvider.dueDate,
                                  (date) => surveyProvider.setDueDate(date),
                                ),
                            formattedDate: surveyProvider.formatDate(
                              surveyProvider.dueDate,
                            ),
                          ),

                          // Assigned To
                          _buildFieldLabel('Assigned To'),
                          _buildTextField(
                            hintText: 'Enter assignee name',
                            value: surveyProvider.assignedTo,
                            onChanged:
                                (value) => surveyProvider.setAssignedTo(value),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter assignee name';
                              }
                              return null;
                            },
                          ),

                          // Assigned By (non-editable)
                          _buildFieldLabel('Assigned By'),
                          _buildReadOnlyField(surveyProvider.assignedBy),

                          const SizedBox(height: 24),

                          // Submit Button
                          // Replace the existing button implementation with this:
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Create Survey',
                              isLoading: surveyProvider.isLoading,
                              onPressed:
                                  surveyProvider.isLoading
                                      ? null
                                      : () async {
                                        // Debug print current form data (only visible to developers)
                                        surveyProvider.debugFormData();

                                        if (_formKey.currentState!.validate()) {
                                          // Check if dates are selected
                                          if (surveyProvider.commencementDate ==
                                              null) {
                                            _showErrorSnackBar(
                                              context,
                                              'Please select commencement date',
                                            );
                                            debugPrint(
                                              'Submission failed: Commencement date not selected',
                                            );
                                            return;
                                          }

                                          if (surveyProvider.dueDate == null) {
                                            _showErrorSnackBar(
                                              context,
                                              'Please select due date',
                                            );
                                            debugPrint(
                                              'Submission failed: Due date not selected',
                                            );
                                            return;
                                          }

                                          // Check if due date is after commencement date
                                          if (surveyProvider.dueDate!.isBefore(
                                            surveyProvider.commencementDate!,
                                          )) {
                                            _showErrorSnackBar(
                                              context,
                                              'Due date must be after commencement date',
                                            );
                                            debugPrint(
                                              'Submission failed: Due date before commencement date',
                                            );
                                            return;
                                          }

                                          try {
                                            // Submit the survey
                                            debugPrint('Calling submitSurvey');
                                            final success =
                                                await surveyProvider
                                                    .submitSurvey();

                                            if (success) {
                                              debugPrint(
                                                'Survey created successfully',
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Survey created successfully',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );

                                              Navigator.pop(context);
                                            } else {
                                              // Show user-friendly error message
                                              if (surveyProvider
                                                      .userErrorMessage !=
                                                  null) {
                                                _showErrorSnackBar(
                                                  context,
                                                  surveyProvider
                                                      .userErrorMessage!,
                                                );
                                              } else {
                                                _showErrorSnackBar(
                                                  context,
                                                  'Failed to create survey. Please try again.',
                                                );
                                              }
                                              // Technical details logged in the provider method
                                            }
                                          } catch (e) {
                                            // Log detailed error for developers
                                            debugPrint(
                                              'Exception during survey creation: $e',
                                            );

                                            // Show user-friendly message
                                            _showErrorSnackBar(
                                              context,
                                              'Unable to create survey. Please try again later.',
                                            );
                                          }
                                        } else {
                                          debugPrint('Form validation failed');
                                        }
                                      },
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textSize: 16,
                              borderRadius: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to show field labels
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField({
    required String hintText,
    required String value,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: value,
        maxLines: maxLines,
        autovalidateMode: AutovalidateMode.onUserInteraction, // Added here
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  // Helper method to build read-only fields
  Widget _buildReadOnlyField(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Text(
          value,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }

  // Helper method to build date picker fields
  Widget _buildDateField({
    required BuildContext context,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    required String formattedDate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate == null ? 'Select date' : formattedDate,
                style: TextStyle(
                  color: selectedDate == null ? Colors.grey[600] : Colors.black,
                  fontSize: 16,
                ),
              ),
              const Icon(Icons.calendar_today, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to show date picker
  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 30),
      ), // Allow selection of recent past dates
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AllColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  // Helper method to show error messages
  // Update your existing _showErrorSnackBar method
  void _showErrorSnackBar(BuildContext context, String message) {
    // Only log that we're showing an error, not the message itself (which is shown to the user)
    debugPrint('Showing error SnackBar to user');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
