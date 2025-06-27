import 'package:flutter/material.dart';

class EventCreation extends StatelessWidget{
  const EventCreation({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                InkWell(
                  onTap: (){Navigator.pop(context);},
                  child: Icon(Icons.close, size: 35),
                ),
                Expanded(child: SizedBox()),
              ]
            )
          ),
          Text('Evenement Aanmaken'),
          Expanded(child: SizedBox()),
        ],
      ),
      children: [
        Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
          child: Column(
            children: [
              Row(
                children: [
                  Text("Text"),
                  //Clickable Startdate & Clickable Enddate with Popup Calendar for each (Default Today, Now)
                  //TextField Name (Default "Evenement Naam")
                  //TextField Description (Default "Evenement Beschrijving")
                  //Map to select location
                  //Button (Default "Maak Evenement Aan")
                ],
              ),
              Row(),
            ]
          ),
        ),
      ],
    );
  }
}