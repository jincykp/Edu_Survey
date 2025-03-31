import 'package:hive/hive.dart';
import 'package:edusurvey/data/model/survey_model.dart';

class HiveSurveyService {
  static const String surveyBoxName = 'surveyBox';

  Future<void> addSurvey(SurveyModel survey) async {
    final box = await Hive.openBox<SurveyModel>(surveyBoxName);
    await box.put(
      survey.referenceNumber,
      survey,
    ); // Using referenceNumber as key
  }

  Future<SurveyModel?> getSurvey(String referenceNumber) async {
    final box = await Hive.openBox<SurveyModel>(surveyBoxName);
    return box.get(referenceNumber);
  }

  Future<List<SurveyModel>> getAllSurveys() async {
    final box = await Hive.openBox<SurveyModel>(surveyBoxName);
    return box.values.toList();
  }

  Future<void> deleteSurvey(String referenceNumber) async {
    final box = await Hive.openBox<SurveyModel>(surveyBoxName);
    await box.delete(referenceNumber);
  }

  Future<void> clearSurveys() async {
    final box = await Hive.openBox<SurveyModel>(surveyBoxName);
    await box.clear();
  }
}
