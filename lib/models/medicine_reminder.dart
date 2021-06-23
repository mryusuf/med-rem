import 'package:hive/hive.dart';

part 'medicine_reminder.g.dart';

@HiveType(typeId: 1)
class MedicineReminder {
  @HiveField(0)
  int medicineID;
  @HiveField(1)
  int hour;
  @HiveField(2)
  int minute;
  @HiveField(3)
  bool isActive;

  MedicineReminder({required this.medicineID, required this.hour, required this.minute, required this.isActive});
}