// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurveyModelAdapter extends TypeAdapter<SurveyModel> {
  @override
  final int typeId = 2;

  @override
  SurveyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyModel(
      surveyName: fields[0] as String,
      referenceNumber: fields[1] as String,
      description: fields[2] as String,
      commencementDate: fields[3] as DateTime,
      dueDate: fields[4] as DateTime,
      assignedTo: fields[5] as String,
      assignedBy: fields[6] as String,
      dateCreated: fields[7] as DateTime,
      status: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.surveyName)
      ..writeByte(1)
      ..write(obj.referenceNumber)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.commencementDate)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.assignedTo)
      ..writeByte(6)
      ..write(obj.assignedBy)
      ..writeByte(7)
      ..write(obj.dateCreated)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
