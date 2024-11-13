// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_usage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataUsageAdapter extends TypeAdapter<DataUsage> {
  @override
  final int typeId = 0;

  @override
  DataUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataUsage(
      usage: fields[0] as double,
      timestamp: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DataUsage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.usage)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
