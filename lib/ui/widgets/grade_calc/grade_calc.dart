import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/services/user_db.dart';

class GradeWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    List temp = [];
    Provider.of<UserDB>(context).courseGradesMap.forEach((key, value) { temp.add([key,value[0],value[1]]); });

    Widget gradeCardMaker(int index){
      return Card(
        color: Colors.white,
        child: ClipPath(
          child: Container(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        temp[index][0],
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Points: ' + temp[index][1].toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Grade: ' + temp[index][2].toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            // height: 100,
            decoration: BoxDecoration(
                border: Border(bottom:BorderSide(color: Colors.blueAccent, width: 5) ,top: BorderSide(color: Colors.blueAccent, width: 5))
            ),
          )
          ,
          clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3))),
        ),
      );
    }
    int c;
    if(MediaQuery.of(context).size.width/4<=150){
      c=2;
    } else if(MediaQuery.of(context).size.width/6<=150){
      c=4;
    } else if(MediaQuery.of(context).size.width/8<=150){
      c=6;
    } else {
      c=8;
    }
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Grades")),),
      drawer: NavigationDrawer(),
      body: Center(
        child: GridView.count(
          childAspectRatio: 1,
          crossAxisCount: c,
          children: List.generate(
              temp.length,
                  (index) => gradeCardMaker(index)
          ),
        ),
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
                              coursePoints = double.tryParse(str);
                              coursePoints ??= int.tryParse(str)?.toDouble();
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Grade",
                            ),
                            onChanged: (String str){
                              courseGrade = double.tryParse(str);
                              courseGrade ??= int.tryParse(str)?.toDouble();
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