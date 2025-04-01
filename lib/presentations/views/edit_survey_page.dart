import 'package:edusurvey/core/theme/colors.dart';
import 'package:edusurvey/data/model/survey_model.dart';
import 'package:edusurvey/view_models/survey_provider.dart';
import 'package:edusurvey/presentations/widgets/custom_sign_buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditSurveyScreen extends StatefulWidget {
  final SurveyModel survey;

  const EditSurveyScreen({Key? key, required this.survey}) : super(key: key);

  @override
  _EditSurveyScreenState createState() => _EditSurveyScreenState();
}

class _EditSurveyScreenState extends State<EditSurveyScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialize the provider with existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final surveyProvider = Provider.of<SurveyFormProvider>(
        context,
        listen: false,
      );
      surveyProvider.setSurveyName(widget.survey.surveyName);
      surveyProvider.setDescription(widget.survey.description);
      surveyProvider.setAssignedTo(widget.survey.assignedTo);
      surveyProvider.setAssignedBy(widget.survey.assignedBy);
      surveyProvider.setCommencementDate(widget.survey.commencementDate);
      surveyProvider.setDueDate(widget.survey.dueDate);
      // Important: set the reference number to match the existing survey
      surveyProvider.setExistingReferenceNumber(widget.survey.referenceNumber);
    });
  }

  Future<void> _updateSurvey() async {
    final surveyProvider = Provider.of<SurveyFormProvider>(
      context,
      listen: false,
    );

    if (_formKey.currentState!.validate()) {
      // Check if dates are selected
      if (surveyProvider.commencementDate == null) {
        _showErrorSnackBar(context, 'Please select commencement date');
        return;
      }

      if (surveyProvider.dueDate == null) {
        _showErrorSnackBar(context, 'Please select due date');
        return;
      }

      // Check if due date is after commencement date
      if (surveyProvider.dueDate!.isBefore(surveyProvider.commencementDate!)) {
        _showErrorSnackBar(context, 'Due date must be after commencement date');
        return;
      }

      try {
        surveyProvider.setIsLoading(true);

        // Create updated survey with the same reference number but updated fields
        final updatedSurvey = SurveyModel(
          surveyName: surveyProvider.surveyName,
          referenceNumber: widget.survey.referenceNumber,
          description: surveyProvider.description,
          commencementDate: surveyProvider.commencementDate!,
          dueDate: surveyProvider.dueDate!,
          assignedTo: surveyProvider.assignedTo,
          assignedBy: widget.survey.assignedBy, // Keep original assigner
          dateCreated: widget.survey.dateCreated, // Keep original creation date
          status: widget.survey.status, // Keep original status
        );

        // Get the repository through provider - use the public getter
        final repository = surveyProvider.surveyRepository;

        // Delete the old survey
        await repository.deleteSurvey(widget.survey.referenceNumber);

        // Create the updated survey
        await repository.createSurvey(updatedSurvey);

        surveyProvider.setIsLoading(false);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Survey updated successfully'),
            backgroundColor: AllColors.successColor,
          ),
        );

        // Navigate back to home screen
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate successful update
      } catch (e) {
        surveyProvider.setIsLoading(false);
        _showErrorSnackBar(context, 'Failed to update survey: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: AllColors.primaryColor,
        title: const Text(
          'Edit Survey',
          style: TextStyle(
            color: AllColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Consumer<SurveyFormProvider>(
        builder: (context, surveyProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reference Number (Read-only)
                  _buildFieldLabel('Reference Number'),
                  _buildReadOnlyField(widget.survey.referenceNumber),

                  // Survey Name
                  _buildFieldLabel('Survey Name'),
                  buildTextField(
                    hintText: 'Enter survey name',
                    value: surveyProvider.surveyName,
                    onChanged: (value) => surveyProvider.setSurveyName(value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a survey name';
                      }
                      return null;
                    },
                  ),

                  // Description
                  _buildFieldLabel('Detailed Description'),
                  buildTextField(
                    hintText: 'Enter detailed description',
                    value: surveyProvider.description,
                    onChanged: (value) => surveyProvider.setDescription(value),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),

                  // Date fields in separate rows to fix overflow
                  _buildFieldLabel('Commencement Date'),
                  _buildDateField(
                    context: context,
                    selectedDate: surveyProvider.commencementDate,
                    onTap:
                        () => _selectDate(
                          context,
                          surveyProvider.commencementDate,
                          (date) => surveyProvider.setCommencementDate(date),
                        ),
                    formattedDate: surveyProvider.formatDate(
                      surveyProvider.commencementDate,
                    ),
                  ),

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
                  buildTextField(
                    hintText: 'Enter assignee name',
                    value: surveyProvider.assignedTo,
                    onChanged: (value) => surveyProvider.setAssignedTo(value),
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

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Update Survey',
                      isLoading: surveyProvider.isLoading,
                      onPressed:
                          surveyProvider.isLoading ? null : _updateSurvey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textSize: 16,
                      borderRadius: 8,
                    ),
                  ),
                ],
              ),
            ),
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
  Widget buildTextField({
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
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

  // Helper method to build date picker fields - modified with reduced padding
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedDate == null ? 'Select date' : formattedDate,
                  style: TextStyle(
                    color:
                        selectedDate == null ? Colors.grey[600] : Colors.black,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
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
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
  void _showErrorSnackBar(BuildContext context, String message) {
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
