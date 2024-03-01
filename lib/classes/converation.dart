import 'package:cloud_firestore/cloud_firestore.dart';

///Represents a conversation in the app
class TwysheConversation{

final int count;
final String id; 
final String message; 
final String name; 
final String owner; 
final Timestamp posted;
final String recipient;
final int status;


///Creates a new conversation
TwysheConversation(this.id, this.count, this.message, this.name, this.owner, this.posted, this.recipient, this.status);

}