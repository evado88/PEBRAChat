import 'package:cloud_firestore/cloud_firestore.dart';

///Represents a discussion chat in the app
class TwysheConversation{

final String ref; 
final String user; 
final String nickname; 
final String pn;
final Timestamp posted;
final int status;
final int posts;


///Creates a new conversation
TwysheConversation(this.ref, this.user, this.nickname, this.pn, this.posted, this.status, this.posts);

}