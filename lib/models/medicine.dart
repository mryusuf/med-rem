import 'package:hive/hive.dart';
part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject{
  @HiveField(0)
  String name;
  @HiveField(1)
  String dose;
  @HiveField(2)
  int color;
  @HiveField(3)
  String intakeTime;
  @HiveField(4)
  bool hasReminder;

  Medicine({required this.name, required this.dose, required this.color, required this.intakeTime, required this.hasReminder});
}
