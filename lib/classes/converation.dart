import 'package:cloud_firestore/cloud_firestore.dart';

///Represents a discussion chat in the app
class TwysheConversation{

final String ref; 
final String user; 
final String nickname; 
final Timestamp posted;
final int status;
final int posts;
final String pnPhone;
final String pnColor;
final String pnName;

///Creates a new conversation
TwysheConversation(this.ref, this.user, this.nickname, this.pnPhone, this.posted, this.status, this.posts, this.pnColor, this.pnName);

}