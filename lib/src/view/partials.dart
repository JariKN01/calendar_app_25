import 'package:flutter/material.dart';

// Default divider between items
Widget divider(BuildContext context) {
  return Divider(
    color: Colors.black,
    indent: 20,
    endIndent: 20,
  );
}

Widget formInput(BuildContext context, TextEditingController controller,
    String label, { String? Function(String?)? validator, }) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary
      ),
      border: OutlineInputBorder(),
      filled: true,
    ),
    validator: validator ?? (value) => null, // Default validator does nothing,
  );
}

Widget defaultContainer(BuildContext context, Widget child) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    padding: EdgeInsets.all(20),
    margin: EdgeInsets.all(10),
    child: child,
  );
}