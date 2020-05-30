 import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:videocalling/Modal/Events.dart';
import 'package:videocalling/Services/FireBaseMessaging.dart';
import 'package:videocalling/screens/videoConferencing.dart';
class StudentEvent extends StatefulWidget {
  @override
  _StudentEventState createState() => _StudentEventState();
}

class _StudentEventState extends State<StudentEvent> {
  List<EventsModal> _allEvent;
  Query _query;
  final dbRef = FirebaseDatabase.instance;    
  StreamSubscription<Event> _onDataAddedSubscription;
  StreamSubscription<Event> _onDataChangedSubscription;
  StreamSubscription<Event> _onDataRemovedSubscription;
  final FirebaseMessaging _firebaseMessaging=FirebaseMessaging();
  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService();
  @override
  void initState() {
    _allEvent=[];

  _initializeevent();
  storeTokenintoDatabase();
    super.initState();
  }
 void storeTokenintoDatabase() async {
    _firebaseMessaging.getToken().then((token){
       print("/////////-----.........");
       print("........$token.............");

        final dbref=FirebaseDatabase.instance.reference();
        dbref.child('institute').child('0').child('branches').child('0').child('students').child('uid').update({
          "tokenid":token.toString()
        });
      
      });
  }

  _initializeevent() {
    _query = dbRef
        .reference()
        .child('institute')
        .child('0')
        .child('branches')
        .child('0')
        .child('events');
    _onDataAddedSubscription = _query.onChildAdded.listen(onEventAdded);
    _onDataChangedSubscription = _query.onChildChanged.listen(onEventChanged);
    _onDataRemovedSubscription = _query.onChildRemoved.listen(onEventRemoved);
    _firebaseMessagingService.sendNotification();
    
  }

  onEventAdded(Event event) {
    setState(() {
      print(event.snapshot.key);
      if (event.snapshot.key != null && event.snapshot.value['courseid']=="517067432") {
              _allEvent.add(EventsModal(
              event.snapshot.value['title'],
              event.snapshot.value['description'],
              event.snapshot.value['time'],
              event.snapshot.value['eventkey'],
              event.snapshot.value['isStarted'],
              event.snapshot.value['courseid'],
              event.snapshot.value['subject']));
      }
    });
  }
  onEventRemoved(Event event) {

    print(_allEvent);
    _allEvent.forEach((element) {
      if(element.eventkey==event.snapshot.value['eventkey']){
        var index=_allEvent.indexOf(element);
        print(_allEvent[index]);
       setState(() {
        _allEvent.removeAt(index);

       });
      }
    });
  }
onEventChanged(Event event) {
    
    print(_allEvent);
    _allEvent.forEach((element) {
      if(element.eventkey==event.snapshot.value['eventkey']){
        var index=_allEvent.indexOf(element);
        print(_allEvent[index]);
       setState(() {
        _allEvent[index] =
          EventsModal(
              event.snapshot.value['title'],
              event.snapshot.value['description'],
              event.snapshot.value['time'],
              event.snapshot.value['eventkey'],
              event.snapshot.value['isStarted'],
              event.snapshot.value['courseid'],
              event.snapshot.value['subject']
              );
       });
      }
    });
  }


  @override
  void dispose() {
    _onDataAddedSubscription.cancel();
    _onDataChangedSubscription.cancel();
    _onDataRemovedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Events'),
      ),

      body:  ListView.builder(
      itemCount: _allEvent.length,
      itemBuilder: (BuildContext context, int index) {
         
        return Card(
            color: Colors.white12,
            elevation: 2.0,
            child: ListTile(
              leading: IconButton(
                icon: Icon(Icons.video_call),
                color: _allEvent[index].isStarted==1?Colors.orange: Colors.grey,
                onPressed: (){
                  if(_allEvent[index].isStarted==1){
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return VideoConferencing(room: _allEvent[index].title, subject: _allEvent[index].description,);
                  }));
                  }

                },
                
              ),
              title: Text(
                 _allEvent[index].title +" (" +_allEvent[index].subject+")" ,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
              _allEvent[index].description,
                    style:
                        TextStyle(fontSize: 13.0, fontWeight: FontWeight.w300),
              ),
              trailing: Text(
                (_allEvent[index].time),
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                  
                  
                }

            ));
      },
    )
        
      
    );
  }
}