import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meeting_listener.dart';

class VideoConferencing extends StatefulWidget {
  final String passVariable;
  final String room;
  final String subject;
  final int privilegelevel;
  VideoConferencing({this.passVariable, this.room, this.subject, this.privilegelevel});
  @override
  _VideoConferencingState createState() {
    
    if(privilegelevel==2)
    return _VideoConferencingState(passVariable: passVariable, privilegelevel: privilegelevel);
    else
    return _VideoConferencingState(room: room, subject: subject, privilegelevel: privilegelevel);
    }
}

class _VideoConferencingState extends State<VideoConferencing> {
  final String passVariable;
  final String room;
  final String subject;
  int privilegelevel;
  _VideoConferencingState({this.passVariable, this.room, this.subject, this.privilegelevel});
  final serverText = TextEditingController();
  final roomText = TextEditingController();
  final subjectText = TextEditingController();
  final nameText = TextEditingController();
  final emailText = TextEditingController();
  //final iosAppBarRGBAColor = TextEditingController(text: "#0080FF80");//transparent blue
  var isAudioOnly = true;
  var isAudioMuted = true;
  var isVideoMuted = true;
  
  final dbRef = FirebaseDatabase.instance;

  _loaddatafromdatabase() async{

     dbRef.reference().child('institute').child('0').child('branches').child('0').child('events').child(passVariable).once().
     then((DataSnapshot value) {
       //print(value.value['description']);
      setState(() {
        roomText.text=value.value['title'];
        subjectText.text=value.value['description'];
      }); 
     });

  }
  @override
  void initState() {
    super.initState();

    privilegelevel=1;

    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
    if(privilegelevel==2){
      _loaddatafromdatabase();
    }   
    else{
      setState(() {
        roomText.text= room;
        subjectText.text= subject;
      });
    }
    
  }
  
  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Video Conferencing'),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // SizedBox(
                //   height: 24.0,
                // ),
                // TextField(
                //   controller: serverText,
                //   decoration: InputDecoration(
                //       border: OutlineInputBorder(),
                //       labelText: "Server URL",
                //       hintText: "Hint: Leave empty for meet.jitsi.si"),
                // ),
                SizedBox(
                  height: 16.0,
                ),
                TextField(
                  controller: roomText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Room",
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextField(
                  controller: subjectText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Subject",
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextField(
                  controller: nameText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Display Name",
                    hintText: "Enter Your Name"
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextField(
                  controller: emailText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "EmailId",
                    hintText: "Enter your Email Id"
                  ),
                ),
                // SizedBox(
                //   height: 16.0,
                // ),
                // TextField(
                //   controller: iosAppBarRGBAColor,
                //   decoration: InputDecoration(
                //       border: OutlineInputBorder(),
                //       labelText: "AppBar Color(IOS only)",
                //       hintText: "Hint: This HAS to be in HEX RGBA format"),
                // ),
                SizedBox(
                  height: 16.0,
                ),
                CheckboxListTile(
                  title: Text("Audio Only"),
                  value: isAudioOnly,
                  onChanged: _onAudioOnlyChanged,
                ),
                SizedBox(
                  height: 16.0,
                ),
                CheckboxListTile(
                  title: Text("Audio Muted"),
                  value: isAudioMuted,
                  onChanged: _onAudioMutedChanged,
                ),
                SizedBox(
                  height: 16.0,
                ),
                CheckboxListTile(
                  title: Text("Video Muted"),
                  value: isVideoMuted,
                  onChanged: _onVideoMutedChanged,
                ),
                Divider(
                  height: 48.0,
                  thickness: 2.0,
                ),
                SizedBox(
                  height: 64.0,
                  width: double.maxFinite,
                  child: RaisedButton(
                    onPressed: () {
                      _joinMeeting();
                    },
                    child: Text(
                     privilegelevel==2? "Create Meeting":"Join Meeting",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.orange,
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
              ],
            ),
          ),
        ),
      );
    
  }

  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _makeupdate() async{
    if(privilegelevel==2){
    dbRef.reference().child('institute').child('0').child('branches').child('0').child('events').child(passVariable).update({
      'isStarted':1, 
    });
  }
  }

  _joinMeeting() async {

   _makeupdate();
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      var options = JitsiMeetingOptions()
        ..room = roomText.text
        ..serverURL = serverUrl
        ..subject = subjectText.text
        ..userDisplayName = nameText.text
        ..userEmail = emailText.text
        //..iosAppBarRGBAColor = iosAppBarRGBAColor.text
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted;

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(options,
          listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
            debugPrint("${options.room} will join with message: $message");
          }, onConferenceJoined: ({message}) {
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: ({message}) {
            if(privilegelevel==2){
            dbRef.reference().child('institute').child('0').child('branches').child('0').child('events').child(passVariable).update({
           'isStarted':0, 
           });
            }
            debugPrint("${options.room} terminated with message: $message");
          }));
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  void _onConferenceWillJoin({message}) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined({message}) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated({message}) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");

  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}