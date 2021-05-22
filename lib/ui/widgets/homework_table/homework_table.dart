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
    if(Provider.of<UserDB>(context).courseOrder.length==0){
      //TODO: Instructions
    }
    List temp = Provider.of<UserDB>(context).homeworkList;
    temp.sort((var a, var b) => a['due'].compareTo(b['due']));
    var courses = Provider.of<UserDB>(context).courseOrder;
    var currentTime = DateTime.now();
    var diff = (int index) => DateTime.fromMillisecondsSinceEpoch(temp[index]['due']).difference(DateTime(currentTime.year,currentTime.month,currentTime.day)).inDays;
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
        borderRadius: BorderRadius.circular(8.0),
        badgeContent: Text(text, style: TextStyle(color: Colors.white)),
      ) : null;
    };

    showHWDialog(String initCourseName, DateTime initDueDate, String initTaskName, Null Function(String, String, DateTime) onConfirm){
      showDialog(
          context: context,
          builder: (BuildContext context){
            String taskName = initTaskName;
            DateTime dueDate = initDueDate;
            var selectedCourse = initCourseName;
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
                          controller: TextEditingController(text: taskName),
                          decoration: InputDecoration(
                            labelText: "Homework Name",
                            hintText: "e.g. HW3",
                          ),
                          onChanged: (String str){
                            taskName = str;
                          },
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8.0,),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: dueDate==null ? Text("Choose Due Date", style: TextStyle(color: Colors.grey)) : Text("Due on:   " + DateFormat('MMM d, y').format(dueDate)),
                        ),
                        onTap: () async{
                          bool useInitDate;
                          useInitDate = initDueDate?.isAfter(DateTime.now()) ?? false;
                          var inputDate = await showDatePicker(context: context, initialDate: useInitDate ? initDueDate : DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2101));
                          setState((){
                            if(inputDate!=null){
                              dueDate = inputDate;
                            }
                          });
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
                          if(selectedCourse==null||taskName==null||dueDate==null){
                            return;
                          }
                          onConfirm(selectedCourse,taskName,dueDate);
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
    }

    Widget gradeCardMaker(int index, double cardWidth){
      var hwData = temp[index];
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
                        hwData['courseName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(hwData['hwName']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          diff(index)>=0 ? "Due on "+DateFormat('MMM d, y').format(DateTime.fromMillisecondsSinceEpoch(hwData['due'])) : "DEADLINE PASSED",
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
                              onPressed: () => showHWDialog(hwData['courseName'], DateTime.fromMillisecondsSinceEpoch(hwData['due']), hwData['hwName'],
                                      (String cn, String tn, DateTime dt) => Provider.of<UserDB>(context,listen: false).editHomework(hwData,cn, tn, dt)),
                              child: const Text('EDIT', style: TextStyle(color: const Color(0xFF6200EE)),)
                          ),
                          TextButton(
                              onPressed: (){
                                Provider.of<UserDB>(context,listen: false).completeHomework(hwData);
                              },
                              child: Text(diff(index)>=0 ? 'MARK AS COMPLETE' : 'ARCHIVE', style: TextStyle(color: const Color(0xFF6200EE)),)
                          ),
                        ],
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
        ),
      );
    }

    int horCount;
    for(horCount=6; horCount>0; --horCount){
      if(MediaQuery.of(context).size.width/horCount>=300){
        break;
      }
    }

    int hwCount = temp.length;
    Widget homeworkContent(int listIndex) {
      int displayCount = max(0,min(hwCount-listIndex*horCount,horCount));
      return Container(
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: List.generate(
              displayCount,
                  (index) => gradeCardMaker(listIndex*horCount + index,MediaQuery.of(context).size.width/horCount)
          ),
        ),
      );
    }

    var quadHome;
    int count;
    for(count=4; count>0; --count){
      if((MediaQuery.of(context).size.height-AppBar().preferredSize.height)/count>=173){
        break;
      }
    }
    if(count==0){
      //TODO: Display "Window too small message"
      quadHome = Container();
    } else {
      quadHome = ListView(
        children: List.generate(hwCount ~/ horCount + (hwCount%horCount>0 ? 1 : 0), (index) => Container(height: (MediaQuery.of(context).size.height-AppBar().preferredSize.height)/count,child: homeworkContent(index))),
        // children: [
        //   Text("height" + MediaQuery.of(context).size.height.toString() + "Width" + MediaQuery.of(context).size.width.toString()),
        //   homeworkContent(0),
        //   homeworkContent(0),
        //   homeworkContent(0),
        //   homeworkContent(0),
        // ],
      );
    }

    var content;
    if (Provider.of<UserDB>(context).courseOrder.isEmpty) {
      content = Text("No courses found. Add some in the Course Table tab!",style: TextStyle(fontSize: 24));
    } else if (Provider.of<UserDB>(context).homeworkList.isEmpty) {
      content = Text("Click on the Plus button to add assignments!",style: TextStyle(fontSize: 24));
    } else {
      content = quadHome;
    }

    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Homework")),),
      drawer: NavigationDrawer(),
      body: Center(child: content),
      floatingActionButton: Provider.of<UserDB>(context).courseOrder.isEmpty ? null : FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          showHWDialog(null, null, null,(String cn, String tn, DateTime dt) => Provider.of<UserDB>(context,listen: false).addHomework(cn, tn, dt));
        },
      ),
    );
  }

}