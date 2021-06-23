import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_reminder/models/medicine.dart';
import 'package:med_reminder/models/medicine_reminder.dart';
import 'package:med_reminder/screens/about.dart';
import 'package:med_reminder/screens/add_medicine.dart';
import 'package:med_reminder/screens/home.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MedicineAdapter());
  Hive.registerAdapter(MedicineReminderAdapter());
  await Hive.openBox<Medicine>("Medicine");
  await Hive.openBox<MedicineReminder>("MedicineReminder");

  runApp(MyApp());
}

final routes = {
  '/home': (BuildContext context) => HomeScreen(),
  '/add-medicine': (BuildContext context) => AddMedicineScreen(),
  '/about': (BuildContext context) => AboutScreen()
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Colors.lightBlue[900],
        accentColor: Colors.cyan[600],

        // Define the default font family.
        textTheme: GoogleFonts.firaSansTextTheme(Theme.of(context).textTheme),
      ),
      home: HomeScreen(),
      routes: routes,
    );
  }
}
