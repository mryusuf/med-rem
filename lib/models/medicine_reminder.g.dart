// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineReminderAdapter extends TypeAdapter<MedicineReminder> {
  @override
  final int typeId = 1;

  @override
  MedicineReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineReminder(
      medicineID: fields[0] as int,
      hour: fields[1] as int,
      minute: fields[2] as int,
      isActive: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineReminder obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.medicineID)
      ..writeByte(1)
      ..write(obj.hour)
      ..writeByte(2)
      ..write(obj.minute)
      ..writeByte(3)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
