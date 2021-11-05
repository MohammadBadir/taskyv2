import 'package:flutter/material.dart';

showBasicDialog(BuildContext context, String message){
  showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(message),
          actions: [
            TextButton(onPressed: ()=>Navigator.of(context).pop(), child: Text("OK"))
          ],
        );
      }
  );
}
