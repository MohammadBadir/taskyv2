import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/models/course_options.dart';
import 'package:tasky/app/services/user_db.dart';

Widget taskyAppBar(context, String title){
  int selectedSemester = Provider.of<UserDB>(context).currentSemester;
  return AppBar(
    title: Center(child: Text(title)),
    actions: true ? null : [
      DropdownButton(
        value: selectedSemester,
        items: Provider.of<UserDB>(context).semesterOrder.map((var x) => DropdownMenuItem(child: Text(x),value: Provider.of<UserDB>(context).semesterOrder.indexOf(x),)).toList() + [DropdownMenuItem(child: Text("Add Semester"), value: -1)],
        onChanged: (var x){
          if(x==-1){
            //addsemester
          } else {
            Provider.of<UserDB>(context, listen: false).changeSemester(x);
          }
        },
      ),
      IconButton(onPressed: (){}, icon: Icon(Icons.settings))
    ],
  );
}