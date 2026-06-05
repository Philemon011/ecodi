// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressModelAdapter extends TypeAdapter<ProgressModel> {
  @override
  final int typeId = 2;

  @override
  ProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressModel(
      courseId: fields[0] as int,
      audioId: fields[1] as int,
      position: fields[2] as double,
      dureeAudio: fields[3] as double,
      termine: fields[4] as bool,
      derniereLecture: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.courseId)
      ..writeByte(1)
      ..write(obj.audioId)
      ..writeByte(2)
      ..write(obj.position)
      ..writeByte(3)
      ..write(obj.dureeAudio)
      ..writeByte(4)
      ..write(obj.termine)
      ..writeByte(5)
      ..write(obj.derniereLecture);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
