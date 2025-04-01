import 'package:edusurvey/data/repositories/survey_repositories.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:edusurvey/data/model/survey_model.dart';

// Survey Form Provider for State Management
class SurveyFormProvider extends ChangeNotifier {
  String _surveyName = '';
  String _referenceNumber = '';
  String _description = '';
  String _assignedTo = '';
  String _assignedBy = '';
  DateTime? _commencementDate;
  DateTime? _dueDate;
  bool _isLoading = false;
  String? _userErrorMessage; // User-friendly error message

  final SurveyRepository _surveyRepository = SurveyRepository();

  // Getters
  String get surveyName => _surveyName;
  String get referenceNumber => _referenceNumber;
  String get description => _description;
  String get assignedTo => _assignedTo;
  String get assignedBy => _assignedBy;
  DateTime? get commencementDate => _commencementDate;
  DateTime? get dueDate => _dueDate;
  bool get isLoading => _isLoading;
  String? get userErrorMessage => _userErrorMessage;
  // Add repository getter
  SurveyRepository get surveyRepository => _surveyRepository;

  // Setters
  void setSurveyName(String name) {
    _surveyName = name;
    debugPrint('SurveyName set to: $name');
    notifyListeners();
  }

  void setReferenceNumber() {
    final random = Random();
    _referenceNumber = "SRV-${random.nextInt(900000) + 100000}";
    debugPrint('ReferenceNumber generated: $_referenceNumber');
    notifyListeners();
  }

  // Add method to set specific reference number
  void setExistingReferenceNumber(String referenceNumber) {
    _referenceNumber = referenceNumber;
    debugPrint('ReferenceNumber set to existing: $referenceNumber');
    notifyListeners();
  }

  void setDescription(String description) {
    _description = description;
    debugPrint('Description set to: $description');
    notifyListeners();
  }

  void setAssignedTo(String assignedTo) {
    _assignedTo = assignedTo;
    debugPrint('AssignedTo set to: $assignedTo');
    notifyListeners();
  }

  void setAssignedBy(String assignedBy) {
    _assignedBy = assignedBy;
    debugPrint('AssignedBy set to: $assignedBy');
    notifyListeners();
  }

  void setCommencementDate(DateTime? date) {
    _commencementDate = date;
    debugPrint('CommencementDate set to: ${formatDate(date)}');
    notifyListeners();
  }

  void setDueDate(DateTime? date) {
    _dueDate = date;
    debugPrint('DueDate set to: ${formatDate(date)}');
    notifyListeners();
  }

  void setIsLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setUserErrorMessage(String? message) {
    _userErrorMessage = message;
    notifyListeners();
  }

  // Initialize form with random reference number and current user
  void initializeForm(String? currentUserName) {
    setReferenceNumber();
    if (currentUserName != null) {
      setAssignedBy(currentUserName);
    }
    debugPrint(
      'Form initialized with referenceNumber: $_referenceNumber and assignedBy: $_assignedBy',
    );
  }

  // Format date for display
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // Validate the form data
  bool validateForm() {
    debugPrint('Validating form data...');

    if (_surveyName.isEmpty) {
      setUserErrorMessage('Please enter a survey name');
      debugPrint('Validation failed: Survey name empty');
      return false;
    }

    if (_description.isEmpty) {
      setUserErrorMessage('Please enter a detailed description');
      debugPrint('Validation failed: Description empty');
      return false;
    }

    if (_commencementDate == null) {
      setUserErrorMessage('Please select a commencement date');
      debugPrint('Validation failed: Commencement date not selected');
      return false;
    }

    if (_dueDate == null) {
      setUserErrorMessage('Please select a due date');
      debugPrint('Validation failed: Due date not selected');
      return false;
    }

    if (_dueDate!.isBefore(_commencementDate!)) {
      setUserErrorMessage('Due date must be after commencement date');
      debugPrint('Validation failed: Due date before commencement date');
      return false;
    }

    if (_assignedTo.isEmpty) {
      setUserErrorMessage('Please enter assignee name');
      debugPrint('Validation failed: Assignee name empty');
      return false;
    }

    setUserErrorMessage(null);
    debugPrint('Form validation passed');
    return true;
  }

  // Submit survey data and store in Hive
  Future<bool> submitSurvey() async {
    debugPrint('submitSurvey called');

    // Validate form data first
    if (!validateForm()) {
      debugPrint('Form validation failed, not submitting');
      return false;
    }

    setIsLoading(true);
    debugPrint('Setting isLoading to true');

    try {
      debugPrint(
        'Creating survey model with data: '
        'surveyName: $_surveyName, '
        'referenceNumber: $_referenceNumber, '
        'description: $_description, '
        'commencementDate: ${formatDate(_commencementDate)}, '
        'dueDate: ${formatDate(_dueDate)}, '
        'assignedTo: $_assignedTo, '
        'assignedBy: $_assignedBy',
      );

      // Create a SurveyModel from the current form values
      final survey = SurveyModel(
        surveyName: _surveyName,
        referenceNumber: _referenceNumber,
        description: _description,
        commencementDate: _commencementDate!,
        dueDate: _dueDate!,
        assignedTo: _assignedTo,
        assignedBy: _assignedBy,
        dateCreated: DateTime.now(),
        status: 'Pending', // Default status for new surveys
      );

      debugPrint('Saving survey to Hive...');
      // Save to Hive using the repository
      await _surveyRepository.createSurvey(survey);

      debugPrint('Survey saved successfully to Hive');
      setIsLoading(false);
      return true;
    } catch (e) {
      debugPrint('Error saving survey: $e');

      // Set user-friendly error message
      if (e.toString().contains('HiveError') &&
          e.toString().contains('adapter')) {
        setUserErrorMessage(
          'Unable to save survey data. Please try again later.',
        );
        debugPrint(
          'Technical details: Missing Hive adapter - fix required in app initialization',
        );
      } else if (e.toString().contains('HiveError')) {
        setUserErrorMessage(
          'Unable to save survey data. Please try again later.',
        );
        debugPrint('Technical details: Hive storage error');
      } else {
        setUserErrorMessage('Something went wrong. Please try again.');
        debugPrint('Technical details: Unknown error: $e');
      }

      setIsLoading(false);
      return false;
    }
  }

  // Debug method to print all form data
  void debugFormData() {
    debugPrint('====== SURVEY FORM DATA ======');
    debugPrint('Survey Name: $_surveyName');
    debugPrint('Reference Number: $_referenceNumber');
    debugPrint('Description: $_description');
    debugPrint('Commencement Date: ${formatDate(_commencementDate)}');
    debugPrint('Due Date: ${formatDate(_dueDate)}');
    debugPrint('Assigned To: $_assignedTo');
    debugPrint('Assigned By: $_assignedBy');
    debugPrint('==============================');
  }

  // Method to get all surveys
  Future<List<SurveyModel>> getAllSurveys() async {
    debugPrint('Getting all surveys from Hive');
    return await _surveyRepository.getAllSurveys();
  }

  // Method to get a specific survey
  Future<SurveyModel?> getSurvey() async {
    debugPrint('Getting survey with reference number: $_referenceNumber');
    return await _surveyRepository.getSurveyByReference(_referenceNumber);
  }

  // Method to delete a survey
  Future<void> deleteSurvey() async {
    debugPrint('Deleting survey with reference number: $_referenceNumber');
    await _surveyRepository.deleteSurvey(_referenceNumber);
  }

  // Make sure the updateSurveyStatus method is correctly implemented:
  Future<bool> updateSurveyStatus(
    String referenceNumber,
    String newStatus,
  ) async {
    debugPrint('Updating survey status: $referenceNumber to $newStatus');
    setIsLoading(true);

    try {
      // First get the survey by reference number
      final survey = await _surveyRepository.getSurveyByReference(
        referenceNumber,
      );

      if (survey == null) {
        debugPrint('Survey not found with reference: $referenceNumber');
        setUserErrorMessage('Survey not found');
        setIsLoading(false);
        return false;
      }

      // Create updated survey with new status
      final updatedSurvey = SurveyModel(
        surveyName: survey.surveyName,
        referenceNumber: survey.referenceNumber,
        description: survey.description,
        commencementDate: survey.commencementDate,
        dueDate: survey.dueDate,
        assignedTo: survey.assignedTo,
        assignedBy: survey.assignedBy,
        dateCreated: survey.dateCreated,
        status: newStatus,
      );

      // Delete the old survey
      await _surveyRepository.deleteSurvey(referenceNumber);

      // Create the updated survey
      await _surveyRepository.createSurvey(updatedSurvey);

      debugPrint('Survey status updated successfully');
      setIsLoading(false);
      return true;
    } catch (e) {
      debugPrint('Error updating survey status: $e');
      setUserErrorMessage('Failed to update survey status');
      setIsLoading(false);
      return false;
    }
  }
}
