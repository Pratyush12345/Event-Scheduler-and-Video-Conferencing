import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class FirebaseMessagingService{
   final FlutterLocalNotificationsPlugin flutterlocalnotificationplugin=new FlutterLocalNotificationsPlugin();
   final FirebaseMessaging _firebaseMessaging=FirebaseMessaging();
   
   FirebaseMessagingService(){
     
      //initializing setting
      var android= AndroidInitializationSettings('@mipmap/ic_launcher');
      var ios=IOSInitializationSettings();
      var initializationSettings=InitializationSettings(android, ios);
      flutterlocalnotificationplugin.initialize(initializationSettings);

   }

  sendNotification(){
      
      
     _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (Map<String,dynamic> message) async{
        print('onMessage $message');
        showNotification(message['data']['title'],message['data']['body']);
      },
      onResume: (Map<String,dynamic> message) async{
        print('onResume $message');
      },
      onLaunch: (Map<String,dynamic> message) async{
        print('onlaunch $message');
      }
    );
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound:true, badge: true, alert: true)
    );
    
    
  }

  showNotification(String title, String body) async{
    var android =AndroidNotificationDetails('channelId', 'channelName', 'channelDescription');
    var iOS=IOSNotificationDetails();
    var platform=NotificationDetails(android, iOS);
    await flutterlocalnotificationplugin.show(0, title, body, platform);
  }
  void storeTokenintoDatabase() async {
    _firebaseMessaging.getToken().then((token){
       print("/////////-----.........");
       print("........$token.............");

        final dbref=FirebaseDatabase.instance.reference();
        dbref.child('institute').child('0').child('branches').child('0').child('teachers').child('0').update({
          "tokenid":token.toString()
        });
      
      });
  }
}