import 'package:cloud_firestore/cloud_firestore.dart';

class TwysheUserPresence {

  final String name;
  final Timestamp? timestamp;
  final bool isTyping;
  final bool never;

   TwysheUserPresence({
    required this.name,
    required this.timestamp,
    required this.isTyping,
    required this.never
  });

}