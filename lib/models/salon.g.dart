// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalonAdapter extends TypeAdapter<Salon> {
  @override
  final int typeId = 0;

  @override
  Salon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Salon(
      id: fields[0] as String,
      name: fields[1] as String,
      location: fields[2] as String,
      rating: fields[3] as double,
      services: (fields[4] as List).cast<Service>(),
    );
  }

  @override
  void write(BinaryWriter writer, Salon obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.services);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
