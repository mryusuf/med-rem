import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:med_reminder/screens/about.dart';
import 'package:med_reminder/screens/medicine_reminder.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  initState() {
    super.initState();
  }

  List<Widget> tabs = [MedicineReminderScreen(), AboutScreen()];

  onTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: tabs[_currentTabIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety_rounded), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.info_rounded), label: "About")
          ],
          type: BottomNavigationBarType.fixed,
          onTap: onTapped,
          currentIndex: _currentTabIndex,
          unselectedItemColor: Colors.black26,
          selectedItemColor: Colors.lightGreen,
        ));
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
                  builder: (context) => MedicineReminderScreen(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
