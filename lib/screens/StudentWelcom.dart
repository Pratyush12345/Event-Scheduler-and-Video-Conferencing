 import 'package:flutter/material.dart';
import 'package:videocalling/screens/StudentEvent.dart';
 class StudentWelcome extends StatefulWidget {
  @override
  _StudentWelcomeState createState() => _StudentWelcomeState();
}

class _StudentWelcomeState extends State<StudentWelcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Welcome'),
        actions: [
          IconButton(
             icon: Icon(Icons.add_alert),
             onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> StudentEvent()));
             },)
        ],
      ),
    );
  }
}