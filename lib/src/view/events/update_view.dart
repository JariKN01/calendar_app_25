import 'package:agenda_app/src/controller/events_controller.dart';
import 'package:agenda_app/src/model/event.dart';
import 'package:flutter/material.dart';

class EventUpdate extends StatelessWidget{
  final Event event;
  final EventController controller;

  const EventUpdate({
    super.key, 
    required this.event,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text("Hello, World!", textAlign: TextAlign.center),
    );
  }
}