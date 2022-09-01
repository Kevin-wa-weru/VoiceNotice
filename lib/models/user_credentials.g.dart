// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_credentials.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserRegAdapter extends TypeAdapter<UserReg> {
  @override
  final int typeId = 0;

  @override
  UserReg read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserReg()
      ..userid = fields[1] as String
      ..phone = fields[2] as String
      ..username = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, UserReg obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.userid)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.username);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRegAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
