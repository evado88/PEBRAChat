import 'package:cloud_firestore/cloud_firestore.dart';

///Represents a discussion chat in the app
class TwysheDiscussion{
  
final String ref;

final String title;
final String description;

final String phone;
final String nickname;
final String color;

final int posts;
final Timestamp timestamp;
final String typing;

///Creates a new discussion with the specified phone, nickname, color and pin
TwysheDiscussion(this.ref, this.title, this.description, this.phone, this.nickname, this.color, this.posts, this.timestamp, this.typing);

}