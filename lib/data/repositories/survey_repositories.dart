import 'package:edusurvey/data/database/hive_survey_services.dart';
import 'package:edusurvey/data/model/survey_model.dart';

class SurveyRepository {
  final HiveSurveyService _hiveService = HiveSurveyService();

  Future<void> createSurvey(SurveyModel survey) async {
    await _hiveService.addSurvey(survey);
  }

  Future<SurveyModel?> getSurveyByReference(String referenceNumber) async {
    return await _hiveService.getSurvey(referenceNumber);
  }

  Future<List<SurveyModel>> getAllSurveys() async {
    return await _hiveService.getAllSurveys();
  }

  Future<void> deleteSurvey(String referenceNumber) async {
    await _hiveService.deleteSurvey(referenceNumber);
  }

  Future<void> clearAllSurveys() async {
    await _hiveService.clearSurveys();
  }
}
