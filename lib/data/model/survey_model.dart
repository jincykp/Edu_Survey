import 'package:hive/hive.dart';

part 'survey_model.g.dart';

@HiveType(typeId: 2)
class SurveyModel extends HiveObject {
  @HiveField(0)
  final String surveyName;

  @HiveField(1)
  final String referenceNumber;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime commencementDate;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final String assignedTo;

  @HiveField(6)
  final String assignedBy;

  @HiveField(7)
  final DateTime dateCreated;

  @HiveField(8)
  final String status;

  SurveyModel({
    required this.surveyName,
    required this.referenceNumber,
    required this.description,
    required this.commencementDate,
    required this.dueDate,
    required this.assignedTo,
    required this.assignedBy,
    required this.dateCreated,
    required this.status,
  });
}
