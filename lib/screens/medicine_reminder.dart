import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:med_reminder/models/constants.dart';
import 'package:med_reminder/models/medicine.dart';
import 'package:intl/intl.dart';
import 'package:universal_platform/universal_platform.dart';

class MedicineReminderScreen extends StatefulWidget {
  // MedicineReminderScreen({Key? key}) : super(key: key);

  @override
  _MedicineReminderScreenState createState() {
    return _MedicineReminderScreenState();
  }
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  Box<Medicine>? medicineBox;
  List<Medicine> medicines = [];
  DateTime now = DateTime.now();
  String? selectedGreeting;
  String? day;

  @override
  void initState() {
    super.initState();

    medicineBox = Hive.box("Medicine");
    if (medicineBox != null && medicineBox!.keys.length > 0) {
      for (var key in medicineBox!.keys) {
        var medicine = medicineBox!.get(key)!;
        medicines.add(medicine);
      }
    }

    if (now.hour > 10 && now.hour <= 17) {
      selectedGreeting = greetings[1];
    } else if (now.hour > 17 && now.hour <= 2) {
      selectedGreeting = greetings[2];
    } else {
      selectedGreeting = greetings[0];
    }

    day = "Today is " + DateFormat.MMMMEEEEd().format(now);
    print(medicines.length);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double toolbarHeight = MediaQuery.of(context).size.height * 0.2;
    if (UniversalPlatform.isIOS) {
      toolbarHeight = MediaQuery.of(context).size.height * 0.15;
    }

    Widget _buildAppBar() => Scaffold(
          appBar: AppBar(
            title: RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: selectedGreeting,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              TextSpan(text: "\n"),
              TextSpan(
                  text: day,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white))
            ])),
            centerTitle: false,
            toolbarHeight: toolbarHeight,
          ),
          // body: Container()
          // floatingActionButton:
        );

    Widget _buildEmptyState = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_rounded,
            size: 100,
          ),
          Text(
            "Start by adding a medicine",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );

    Widget _buildMedicineCards = ListView.builder(
      itemBuilder: (context, index) {
        final Medicine medicine = medicines[index];
        return Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          topLeft: Radius.circular(4)),
                      child: Container(
                        height: 80,
                        color: Color(medicine.color),
                      ))),
              Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(medicine.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                            Text(medicine.dose),
                            Text(medicine.intakeTime)
                          ],
                        ),
                        medicine.hasReminder
                            ? Icon(Icons.alarm_on_rounded)
                            : Container()
                      ],
                    ),
                  ))
            ],
          ),
        );
      },
      itemCount: medicines.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(18),
    );

    Widget _buildBody() => Container(
          child: Center(
            child: Container(
                margin: EdgeInsets.only(top: 150),
                width: width,
                decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)))),
                child: medicines.length > 0
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                            child: Text(
                              "Your Medicines",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                if (constraints.maxWidth <= 576) {
                                  return _buildMedicineCards;
                                } else if (constraints.maxWidth <= 768) {
                                  return MedicineGrid(medicines: medicines, gridCount: 2);
                                } else {
                                  return MedicineGrid(medicines: medicines, gridCount: 4);
                                }
                              }
                              
                          )),
                        ],
                      )
                    : _buildEmptyState),
          ),
        );

    Widget _buildFab() => Positioned(
          bottom: 0,
          right: 40,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: FloatingActionButton(
              onPressed: () => {
                Navigator.pushNamed(context, "/add-medicine").then((_) {
                  // Call setState() here to reload cards
                  List<Medicine> updatedMedicines = [];
                  if (medicineBox != null && medicineBox!.keys.length > 0) {
                    for (var key in medicineBox!.keys) {
                      var medicine = medicineBox!.get(key)!;
                      updatedMedicines.add(medicine);
                    }
                  }
                  setState(() {
                    medicines = updatedMedicines;
                    print(medicines);
                  });
                })
              },
              child: Icon(Icons.add),
            ),
          ),
        );

    return Material(
      child: Stack(
        children: [_buildAppBar(), _buildBody(), _buildFab()],
      ),
    );
  }
}

class MedicineGrid extends StatelessWidget {
  List<Medicine> medicines;
  final int gridCount;
  
  MedicineGrid({required this.medicines, required this.gridCount});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: medicines.map((medicine) {
          return Card(
            child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          topLeft: Radius.circular(4)),
                      child: Container(
                        color: Color(medicine.color),
                      ))),
              Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(medicine.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                            Text(medicine.dose),
                            Text(medicine.intakeTime)
                          ],
                        ),
                        medicine.hasReminder
                            ? Icon(Icons.alarm_on_rounded)
                            : Container()
                      ],
                    ),
                  ))
            ],
          ),
          );
        }).toList(),
      
    );
  }
}