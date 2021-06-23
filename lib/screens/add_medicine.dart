import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:hive/hive.dart';
import 'package:med_reminder/models/constants.dart';
import 'package:med_reminder/models/medicine.dart';
import 'package:med_reminder/models/medicine_reminder.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:med_reminder/screens/home.dart';
import 'package:universal_platform/universal_platform.dart';


class AddMedicineScreen extends StatefulWidget {
  AddMedicineScreen({Key? key}) : super(key: key);

  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  
  bool isAndroidOrIOS = UniversalPlatform.isIOS || UniversalPlatform.isAndroid;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  final formKey = GlobalKey<FormState>();

  // save colors value into hive with int value => colors.red.color.value then display value on cards with Color(value)
  List<Color> colors = medicineColors;
  List<String> intakes = medicineIntakes;
  Box<Medicine>? medicineBox;
  Box<MedicineReminder>? medicineReminderBox;

  int? selectedColor = 0;
  String? selectedIntakeString, medicineName, medicineDose;
  bool isReminderActive = false;
  TimeOfDay selectedTime = TimeOfDay(hour: 06, minute: 00);

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    medicineBox = Hive.box("Medicine");
    medicineReminderBox = Hive.box("MedicineReminder");

    print(medicineBox?.keys);
    selectedIntakeString = intakes[0];

    _configureLocalTimeZone();
    if (isAndroidOrIOS) {
      flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double toolbarHeight = height * 0.2;
    if (UniversalPlatform.isIOS) {
      toolbarHeight = height * 0.15;
    }
    double paddingTop = height * 0.1;
    if (UniversalPlatform.isWeb) {
      paddingTop = height * 0.085;
    }

    Widget _appBar() => Scaffold(
          appBar: AppBar(
              title: RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: "Add new",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                TextSpan(text: "\n"),
                TextSpan(
                    text: "Medicine",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white))
              ])),
              centerTitle: false,
              toolbarHeight: toolbarHeight,
              leading: Container(),
          ),
        );

    Widget medicineNameTextField = TextFormField(
      onChanged: (value) {
        medicineName = value;
      },
      validator: (value) {
        if (value == null) {
          return 'This field is required';
        }
      },
      decoration: InputDecoration(
        hintText: "Vitamin D, Paracetamol, etc..",
        labelText: "Name",
      ),
    );

    Widget _doseTextField = TextFormField(
      onChanged: (value) {
        medicineDose = value;
      },
      validator: (value) {
        if (value == null) {
          return 'This field is required';
        }
      },
      decoration: InputDecoration(
        hintText: "2 pill, 1 teaspoon, etc",
        labelText: "Dose",
      ),
    );
    Widget _intakeDropdown = DropdownButton<String>(
      value: selectedIntakeString,
      isExpanded: true,
      icon: const Icon(Icons.arrow_circle_down_outlined),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      onChanged: (String? newValue) {
        setState(() {
          selectedIntakeString = newValue!;
        });
      },
      items: intakes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

    Widget _buildColorField = Container(
        height: 100,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return SizedBox(
              width: 100,
              child: RadioListTile(
                value: index,
                groupValue: selectedColor,
                onChanged: (int? index) =>
                    setState(() => selectedColor = index),
                title: Text(""),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.white,
                tileColor: colors[index],
              ),
            );
          },
          shrinkWrap: true,
          itemCount: colors.length,
          scrollDirection: Axis.horizontal,
        ));

    Widget _buildReminder = SwitchListTile(
      value: isReminderActive,
      title: Text(
        selectedTime.format(context),
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      secondary: Icon(Icons.alarm),
      onChanged: onChangeSwitch,
    );

    Widget _buildSubmitButton = new Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(24),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(15.0),
        height: 50,
        onPressed: _submit,
        child: Text(
          "Submit",
          textAlign: TextAlign.center,
          style:
              new TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      color: Colors.green,
    );

    Widget _buildBody() => SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.only(top: 150),
              width: width,
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)))),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Material(
                  color: Colors.white,
                  // child: Text("hei"),
                  child: Form(
                      key: formKey,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: medicineNameTextField,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: _doseTextField,
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 16, 0, 4),
                                  child: Text(
                                    "Intake time",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 16, color: Colors.black54),
                                  )),
                              _intakeDropdown,
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 16, 0, 4),
                                  child: Text(
                                    "Color",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 16, color: Colors.black54),
                                  )),
                              _buildColorField,
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 16, 0, 4),
                                  child: Text(
                                    "Daily Reminder",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 16, color: Colors.black54),
                                  )),
                              _buildReminder,
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: isLoading
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : _buildSubmitButton),
                            ]),
                      )),
                ),
              ),
            ),
          ),
        );

    return Material(
      child: Stack(
        children: [
          _appBar(),
          _buildBody(),
          Padding(
            padding: EdgeInsets.fromLTRB(15, paddingTop, 0, 0),
            child: CircleAvatar(
              radius: 20,
              child: CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  CupertinoIcons.chevron_back,
                  color: Colors.white,
                ),
                padding: EdgeInsets.fromLTRB(2, 2, 5, 2),
              ),
            ),
          ),
        ],
      ),
      color: Colors.white,
    );
  }

  void _submit() async {
    print("submitting");
    final form = formKey.currentState;
    form?.save();
    bool? isValid = form?.validate();
    if (isValid != null &&
        isValid &&
        medicineName != null &&
        medicineDose != null) {
      print("is valid, saving data");
      setState(() {
        isLoading = true;
      });
      var medicine = Medicine(
          name: medicineName ?? "",
          dose: medicineDose ?? "",
          color: colors[selectedColor ?? 0].value,
          intakeTime: selectedIntakeString ?? "",
          hasReminder: isReminderActive);

      await medicineBox?.add(medicine);

      if (isReminderActive) {
        var medicineReminder = MedicineReminder(
            medicineID: medicine.key,
            hour: selectedTime.hour,
            minute: selectedTime.minute,
            isActive: isReminderActive);

        await medicineReminderBox?.add(medicineReminder);

        await _showDailyReminder(medicine.key, selectedTime, medicineName!);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) {
      print(picked.toString());

      setState(() {
        selectedTime = picked;
      });
    }
  }

  void onChangeSwitch(bool value) {
    if (value == true) {
      _selectTime(context);
    } else if (value == false) {
      _cancelNotification();
    }
    setState(() {
      isReminderActive = value;
    });
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin?.cancel(0);
  }

  Future<void> _showDailyReminder(
      int id, TimeOfDay selectedTime, String medicationName) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime = tz.TZDateTime(tz.local, now.year, now.month,
        now.day, selectedTime.hour, selectedTime.minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      'repeatDailyAtTime description',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    var title = "Med Reminder";
    var body = "It's time to take your meds, " + medicationName;

    await flutterLocalNotificationsPlugin?.zonedSchedule(
        id, title, body, scheduledTime, platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload.isNotEmpty) {
      debugPrint('notification payload: ' + payload);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: title.isNotEmpty ? Text(title) : null,
        content: body.isNotEmpty ? Text(body) : null,
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
