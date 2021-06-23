import 'package:flutter/material.dart';
import 'package:med_reminder/models/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(aboutData["header"] ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            ),
            Image.asset(aboutData["image"] ?? "", width: MediaQuery.of(context).size.width / 2,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(aboutData["name"]  ?? ""),
            ),
            Text(aboutData["email"]  ?? "")
          ],
        ),
      ),
    );
  }
}