import 'package:flutter/material.dart';
import 'package:videocalling/screens/Calender.dart';
import 'package:videocalling/screens/StudentWelcom.dart';
import 'package:videocalling/screens/videoConferencing.dart';
void main() => runApp(MyApp());

 class MyApp extends StatelessWidget {
   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       home: Calender(),
       debugShowCheckedModeBanner: false,
       theme: ThemeData(
         primarySwatch: Colors.orange
       )

     );
   }
 }


