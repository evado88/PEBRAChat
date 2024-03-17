import 'package:cloud_firestore/cloud_firestore.dart';

///Represents a discussion chat in the app
class TwysheConversation{

final String ref; 
final String user; 
final String nickname; 
final Timestamp posted;
final int status;
final int posts;
final String otherPhone;
final String otherColor;
final String otherName;


///Creates a new conversation
TwysheConversation(this.ref, this.user, this.nickname, this.otherPhone, this.posted, this.status, this.posts, this.otherColor, this.otherName);

}