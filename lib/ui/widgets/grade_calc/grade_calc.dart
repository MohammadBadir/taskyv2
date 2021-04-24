import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/services/user_db.dart';

class GradeWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Grades")),),
      drawer: NavigationDrawer(),
      body: Center(
        child: Container(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          showDialog(
              context: context,
              builder: (BuildContext context){
                String courseName;
                double coursePoints;
                double courseGrade;
                return StatefulBuilder(
                  builder: (context, setState){
                    return AlertDialog(
                      title: Text("Enter Course Details"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Name",
                            ),
                            onChanged: (String str){
                              courseName = str;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Points",
                            ),
                            onChanged: (String str){
                              coursePoints = double.parse(str);
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Grade",
                            ),
                            onChanged: (String str){
                              courseGrade = double.parse(str);
                            },
                          )
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                            onPressed: (){
                              if(courseName==null||coursePoints==null||courseGrade==null){
                                return;
                              }
                              Provider.of<UserDB>(context,listen: false).addCourseGrade(courseName, coursePoints, courseGrade);
                              Navigator.of(context).pop();
                            },
                            child: Text("Confirm")
                        ),
                      ],
                    );
                  },
                );
              }
          );
        },
      ),
    );
  }

}