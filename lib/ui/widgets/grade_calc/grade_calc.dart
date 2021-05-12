import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/services/user_db.dart';

class HomeworkWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    //List temp = [];
    //Provider.of<UserDB>(context).courseGradesMap.forEach((key, value) { temp.add([key,value[0],value[1]]); });

    List temp = Provider.of<UserDB>(context).homeworkList;
    temp.sort((var a, var b) => a['due'].compareTo(b['due']));
    var courses = Provider.of<UserDB>(context).courseOrder;
    var a = DateTime.now();
    var b = DateTime(a.year,a.month,a.day);
    var diff = (int index) => DateTime.fromMillisecondsSinceEpoch(temp[index]['due']).difference(b).inDays;
    var trail = (index){
      String text;
      if(diff(index)<0){
        return null;
      }

      if(diff(index)==0){
        text = 'TODAY';
      } else if(diff(index)==1){
        text = diff(index).toString() + ' DAY';
      } else {
        text = diff(index).toString() + ' DAYS';
      }
      return diff(index)<=7 ? Badge(
        badgeColor: diff(index) > 3 ? Colors.orange : Colors.red,
        shape: BadgeShape.square,
        borderRadius: BorderRadius.circular(8.0,),
        badgeContent: Text(text, style: TextStyle(color: Colors.white)),
      ) : null;
    };
    Widget gradeCardMaker(int index, double cardWidth){
      return Container(
        width: cardWidth,
        child: Card(
          color: Colors.white,
          child: ClipPath(
            child: Container(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      trailing: trail(index),
                      leading: Icon(Icons.event_note),
                      title: Text(
                        temp[index]['courseName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(temp[index]['hwName']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          diff(index)>=0 ? "Due on "+DateFormat('MMM d, y').format(DateTime.fromMillisecondsSinceEpoch(temp[index]['due'])) : "DEADLINE PASSED",
                          style: TextStyle(fontSize: 25,),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: (){
                                showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2101));
                              },
                              child: const Text('EDIT', style: TextStyle(color: const Color(0xFF6200EE)),)
                          ),
                          TextButton(
                              onPressed: (){
                                Provider.of<UserDB>(context,listen: false).completeHomework(temp[index]);
                              },
                              child: Text(diff(index)>=0 ? 'MARK AS COMPLETE' : 'ARCHIVE', style: TextStyle(color: const Color(0xFF6200EE)),)
                          ),
                        ],
                      ),
                    )
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(
                    //     'Points: ' + temp[index][1].toString(),
                    //     style: TextStyle(fontSize: 20),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(
                    //     'Grade: ' + temp[index][2].toString(),
                    //     style: TextStyle(fontSize: 20),
                    //   ),
                    // )
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

    var homeworkContent = Expanded(
        child: Container(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(
                temp.length,
                    (index) => gradeCardMaker(index,MediaQuery.of(context).size.width/5)
            ),
          ),
        )
    );

    int count;
    for(count=4; count>0; --count){
      if((MediaQuery.of(context).size.height-AppBar().preferredSize.height)/count>=173){
        break;
      }
    }
    if(count==0){
      //TODO: Display "Window too small message"
    }

    var quadHome = Column(
      children: List.generate(count, (index) => homeworkContent),
      // children: [
      //   Text("height" + MediaQuery.of(context).size.height.toString() + "Width" + MediaQuery.of(context).size.width.toString()),
      //   homeworkContent,
      //   homeworkContent,
      //   homeworkContent,
      //   homeworkContent,
      // ],
    );

    var oldContent = Center(
      child: GridView.count(
        childAspectRatio: 1,
        crossAxisCount: c,
        children: List.generate(
            temp.length,
                (index) => gradeCardMaker(index,MediaQuery.of(context).size.width/5)
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Homework")),),
      drawer: NavigationDrawer(),
      body: quadHome,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          showDialog(
              context: context,
              builder: (BuildContext context){
                String hwName;
                double coursePoints=2;
                double courseGrade=2;
                DateTime dueDate;
                var selectedCourse;
                return StatefulBuilder(
                  builder: (context, setState){
                    return AlertDialog(
                      title: Text("Enter Homework Details"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(8.0,),
                            onTap: (){},
                            child: DropdownButton(
                              value: selectedCourse,
                              items: courses.map((var x) => DropdownMenuItem(child: Text(x),value: x,)).toList(),
                              hint: Text("Choose Course"),
                              onChanged: (var x){
                                setState((){
                                  selectedCourse = x;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Homework Name",
                                hintText: "e.g. HW3"
                              ),
                              onChanged: (String str){
                                hwName = str;
                              },
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8.0,),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: dueDate==null ? Text("Choose Due Date", style: TextStyle(color: Colors.grey),) : Text("Due on:   " + DateFormat('MMM d, y').format(dueDate)),
                            ),
                            onTap: () async{
                              var inputDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2101));
                              setState((){
                                if(inputDate!=null){
                                  dueDate = inputDate;
                                }
                              });
                            },
                          )
                          // TextFormField(
                          //   decoration: InputDecoration(
                          //     labelText: "Points",
                          //   ),
                          //   onChanged: (String str){
                          //     coursePoints = double.tryParse(str);
                          //     coursePoints ??= int.tryParse(str)?.toDouble();
                          //   },
                          // ),
                          // TextFormField(
                          //   decoration: InputDecoration(
                          //     labelText: "Grade",
                          //   ),
                          //   onChanged: (String str){
                          //     courseGrade = double.tryParse(str);
                          //     courseGrade ??= int.tryParse(str)?.toDouble();
                          //   },
                          // )
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
                              if(selectedCourse==null||hwName==null||dueDate==null){
                                return;
                              }
                              Provider.of<UserDB>(context,listen: false).addHomework(selectedCourse, hwName, dueDate);
                              //Provider.of<UserDB>(context,listen: false).addCourseGrade(selected, coursePoints, courseGrade);
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