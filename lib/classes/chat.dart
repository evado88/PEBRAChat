import 'package:cloud_firestore/cloud_firestore.dart';

///Represents a Chat in the app
class TwysheChat{

final String color; 
final int count;
final String id; 
final String? message; 
final String name; 
final String otherName;
final String otherPhone;
final String owner; 
final Timestamp posted;
final int status;
final String typing;

///Creates a new Chat
TwysheChat(this.color, this.count,  this.id, this.message, this.name, this.otherName, this.otherPhone, this.owner, this.posted, this.status, this.typing);

}