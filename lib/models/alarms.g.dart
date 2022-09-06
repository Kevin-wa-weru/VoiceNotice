// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarms.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioStatusAdapter extends TypeAdapter<AudioStatus> {
  @override
  final int typeId = 1;

  @override
  AudioStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioStatus()..playAudio = fields[1] as bool;
  }

  @override
  void write(BinaryWriter writer, AudioStatus obj) {
    writer
      ..writeByte(1)
      ..writeByte(1)
      ..write(obj.playAudio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
