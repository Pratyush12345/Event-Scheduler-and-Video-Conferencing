import 'dart:async';
import 'dart:collection';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:videocalling/Modal/Events.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:videocalling/Modal/random_string.dart';
import 'package:videocalling/Services/FireBaseMessaging.dart';
import 'package:videocalling/screens/SessionDetail.dart';
import 'package:videocalling/screens/videoConferencing.dart';

class Calender extends StatefulWidget {
  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  CalendarController _calendarController;
  String passVariable = "",eventkey="";
  Map<DateTime, List<dynamic>> _events = {};
  final dbRef = FirebaseDatabase.instance;
  StreamSubscription<Event> _onDataAddedSubscription;
  StreamSubscription<Event> _onDataChangedSubscription;
  StreamSubscription<Event> _onDataRemovedSubscription;
  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService();
  Query _query;
  List<dynamic> _selectedEvents = [];
  SharedPreferences _pref;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _initializeevent();
    _sharedprefinit();
  }
   _sharedprefinit () async{
     _pref = await SharedPreferences.getInstance();
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
    _firebaseMessagingService.storeTokenintoDatabase();
  }

  onEventAdded(Event event) {
    setState(() {
      print(event.snapshot.key);
      if (event.snapshot.key != null) {
        String str = event.snapshot.key.substring(0, 10) + 'T12:00:00.000Z';
        DateTime _key = DateTime.parse(str);
        if(event.snapshot.value['teacheruid']=="uid"){
        if (_events[_key] == null)
          _events[_key] = [
            EventsModal(
                event.snapshot.value['title'],
                event.snapshot.value['description'],
                event.snapshot.value['time'],
                event.snapshot.value['eventkey'],
                event.snapshot.value['isStarted'],
                event.snapshot.value['courseid'],
                event.snapshot.value['subject']
                )
          ];
        else
          _events[_key].add(EventsModal(
              event.snapshot.value['title'],
              event.snapshot.value['description'],
              event.snapshot.value['time'],
              event.snapshot.value['eventkey'],
              event.snapshot.value['isStarted'],
              event.snapshot.value['courseid'],
              event.snapshot.value['subject']));
      }
      }
    });
  }
  onEventRemoved(Event event) {
    String str = event.snapshot.key.substring(0, 10) + 'T12:00:00.000Z';
    DateTime _key = DateTime.parse(str);
    print(_events);
    _events[_key].forEach((element) {
      if(element.eventkey==event.snapshot.value['eventkey']){
        var index=_events[_key].indexOf(element);
        print(_events[_key][index]);
       setState(() {
        _events[_key].removeAt(index);

       });
      }
    });
  }
onEventChanged(Event event) {
    String str = event.snapshot.key.substring(0, 10) + 'T12:00:00.000Z';
    DateTime _key = DateTime.parse(str);
    print(_events);
    _events[_key].forEach((element) {
      if(element.eventkey==event.snapshot.value['eventkey']){
        var index=_events[_key].indexOf(element);
        print(_events[_key][index]);
       setState(() {
        _events[_key][index] =
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
    _calendarController.dispose();
    _onDataAddedSubscription.cancel();
    _onDataChangedSubscription.cancel();
    _onDataRemovedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SessionDetail(passVaraible: passVariable, eventkey:eventkey , isedit: false,)));
        },
      ),
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TableCalendar(
              events: _events,
              calendarStyle: CalendarStyle(
                  todayColor: Colors.orange,
                  todayStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white)),
              headerStyle: HeaderStyle(
                  centerHeaderTitle: true,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                  formatButtonShowsNext: false),
              onDaySelected: (date, events) {
                String _month = date.month.toString();
                String _day = date.day.toString();
                if (_month.length == 1) {
                  _month = "0" + _month;
                }
                if (_day.length == 1) {
                  _day = "0" + _day;
                }
                eventkey=randomNumeric(6);
                passVariable = date.year.toString() + "-" +_month +"-" +_day +eventkey;
                 
                print(passVariable);
                print(_calendarController.selectedDay);
                if (events != null) {
                  setState(() {
                    _selectedEvents = events;
                  });
                }
              },
              builders:
                  CalendarBuilders(selectedDayBuilder: (context, date, events) {
                return Container(
                  margin: EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }),
              calendarController: _calendarController),
          ..._selectedEvents.map((e) { 
            int isStarted=e.isStarted;
            return Card(
                color: isStarted==1?Colors.orange: Colors.white30,
                elevation: 2.0,
                child: ListTile(
                  onTap: () {
                    String pass= _pref.getString(e.description);
                    print(pass);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SessionDetail(passVaraible: pass,eventkey: pass.substring(10,16), isedit: true,)));
                  },
                  title: Text( 
                    e.title +" at " + e.time,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    e.description,
                    style:
                        TextStyle(fontSize: 13.0, fontWeight: FontWeight.w300),
                  ),
                  leading: IconButton(
                      onPressed: () {
                       
                          String pass2= _pref.getString(e.description);
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoConferencing(passVariable: pass2)));
                        
                      },
                      icon:  const Icon(Icons.video_call,
                      )),
                ),
              );
          
              
            }) 
        ],
      )),
    );
  }
}
