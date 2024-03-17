
import 'package:flutter/material.dart';

class TwysheMenu {

  final String name;
  final String description;
  final String title;
  final Color? color;
  final IconData icon;
  final dynamic tag;

  TwysheMenu({
    required this.name,
    required this.description,
    required this.title,
    this.color,
    required this.icon,
    this.tag
  });

}