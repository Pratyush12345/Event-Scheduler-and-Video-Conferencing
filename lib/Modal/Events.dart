import 'package:firebase_database/firebase_database.dart';

class EventsModal {
 String title;
 String description; 
 String eventkey;
 String time;
 String courseid;
 String subject;
 int isStarted; 
   EventsModal(this.title, this.description, this.time, this.eventkey, this.isStarted, this.courseid, this.subject);
    
}