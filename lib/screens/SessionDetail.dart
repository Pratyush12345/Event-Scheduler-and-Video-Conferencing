import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionDetail extends StatefulWidget {
  final String passVaraible;
  final String eventkey;
  final bool isedit;
  SessionDetail({this.passVaraible, this.eventkey, this.isedit});
  @override
  _SessionDetailState createState() => _SessionDetailState(passVaraible, eventkey, isedit);
}

class _SessionDetailState extends State<SessionDetail> {
  String passVariable;
  final String eventkey;
  final bool isedit;
  _SessionDetailState(this.passVariable, this.eventkey, this.isedit);
  final titleText = TextEditingController();
  final descriptionText = TextEditingController();
  final dbRef = FirebaseDatabase.instance;
  SharedPreferences _pref;
  String previousDescriptionText="";
  TimeOfDay _time= TimeOfDay.now();
  TimeOfDay _picked;
  String testtime="hh:mm";
  _loaddatafromdatabase() async{

     dbRef.reference().child('institute').child('0').child('branches').child('0').child('events').child(passVariable).once().
     then((DataSnapshot value) {
       //print(value.value['description']);
      setState(() {
        titleText.text=value.value['title'];
        descriptionText.text=value.value['description'];
        testtime=value.value['time'];
        previousDescriptionText=value.value['description'];
      }); 
     });

  }
  _saveintodatabase() async {
    
    _pref.setString(descriptionText.text, passVariable);
    print(passVariable);
    if(isedit && descriptionText.text!=previousDescriptionText)
    {
      _pref.remove(previousDescriptionText);
    }

    dbRef.reference().child('institute').child('0').child('branches').child('0').child('events').child(passVariable).update({
      'title': titleText.text,
      'description':descriptionText.text,
      'time':_time.hour.toString()+":"+_time.minute.toString(),
      'eventkey': eventkey,
      'isStarted':0 ,
      'teacheruid':"uid",
      "courseid": "517067432",
      "subject": "Physics"
    });
    Navigator.of(context).pop();
  }

  _delfromdatabase() async {

    dbRef.reference().child('institute').child('0').child('branches').child('0').child('events').child(passVariable).remove();
    _pref.remove(previousDescriptionText);
    Navigator.of(context).pop();
  }

  Future<Null> _selectTime(BuildContext context) async{
   _picked= await showTimePicker(
     context: context,
     initialTime: _time
   );
   if(_picked!=null){
     setState(() {
     _time= _picked;
      testtime=_time.hour.toString()+":"+_time.minute.toString();
    //  print(_time.hour.toString());
    //  print(_time.minute.toString());
   });
   }
   
  }
  _sharedprefinit () async{
     _pref = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _sharedprefinit();
    if(isedit)
    _loaddatafromdatabase();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Event Detail'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(4.0),
                  child: Column(
            children: <Widget>[
              SizedBox(height: 20.0,),

              TextField(
                  controller: titleText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Title",
                  )),

              SizedBox(height: 20.0,),

              TextField(
                  controller: descriptionText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Description",
                  )),

              SizedBox(height: 20.0,),

              
                  Card(
                    color: Colors.orange,
                    child: ListTile(
                      trailing: Icon(Icons.alarm),
                      title:Text(testtime) ,
                      onTap: (){
                        _selectTime(context);
                      },
                    ),
                    
                  ),

                  
              Divider(
                height: 48.0,
                thickness: 2.0,
              ),

              GestureDetector(
                onTap: () {
                  _saveintodatabase();
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.orange),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20.0,),
              isedit?
              GestureDetector(
                onTap: () {
                  _delfromdatabase();
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.orange),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  child: Text(
                    "Delete Event",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
              :SizedBox(height: 10.0,)

            ],
          ),
        ),
      ),
    );
  }
}
