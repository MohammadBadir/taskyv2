import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/app_bar/tasky_app_bar.dart';
import 'package:tasky/ui/widgets/misc/basic_dialog.dart';

import '../new_course_table/new_course_table.dart';

class TaskWidget extends StatelessWidget{
  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  @override
  Widget build(BuildContext context) {
    //Auxiliary declarations
    List sortedTaskList = Provider.of<UserDB>(context).homeworkList;
    sortedTaskList.sort((var a, var b) => a['due'].compareTo(b['due']));
    var courseList = Provider.of<UserDB>(context).courseOrder;
    var currentTime = DateTime.now();
    int timeDiff(int index) => daysBetween(currentTime, DateTime.fromMillisecondsSinceEpoch(sortedTaskList[index]['due']));
    var remainingTimeBadge = (int index){
      String text;
      if(timeDiff(index)<0){
        return null;
      }
      if(timeDiff(index)==0){
        text = 'TODAY';
      } else if(timeDiff(index)==1){
        text = timeDiff(index).toString() + ' DAY';
      } else {
        text = timeDiff(index).toString() + ' DAYS';
      }
      return (sortedTaskList[index]['taskType']=='exam' || timeDiff(index)<=7) ? Badge(
        badgeColor: timeDiff(index) > 7 ? Color(0xFF23CD0C) : (timeDiff(index) > 3 ? Color(
            0xFFFFBF00) : Colors.red),
        shape: BadgeShape.square,
        borderRadius: BorderRadius.circular(8.0),
        badgeContent: Text(text, style: TextStyle(color: Colors.white)),
      ) : null;
    };

    showHWDialog(String initCourseName, DateTime initDueDate, String initTaskName, String initTaskType, Null Function(String, String, DateTime, String) onConfirm){
      var dropDownCourseList = List.from(courseList);
      dropDownCourseList.add("Other Tasks");
      showDialog(
          context: context,
          builder: (BuildContext context){
            String taskName = initTaskName;
            DateTime dueDate = initDueDate;
            String selectedCourse = initCourseName;
            String taskType = initTaskType;
            return StatefulBuilder(
              builder: (context, setState){
                return AlertDialog(
                  title: Text("Enter Task Details"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButton(
                        focusColor: Colors.transparent,
                        value: selectedCourse,
                        items: dropDownCourseList.map((var x) => DropdownMenuItem(child: Text(x),value: x,)).toList(),
                        hint: Text("Choose Course"),
                        onChanged: (var x){
                          setState((){
                            selectedCourse = x;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: TextFormField(
                          controller: TextEditingController(text: taskName),
                          decoration: InputDecoration(
                            labelText: "Task Name",
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
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: dueDate==null ? Text("Choose Due Date", style: TextStyle(color: Colors.lightBlue)) : Text("Due on:   " + DateFormat('MMM d, y').format(dueDate)),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text("Task Type:"),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8.0,),
                        child: IgnorePointer(
                          child: ListTile(
                            title: Text("Homework"),
                            leading: Radio<String>(
                              value: "hw",
                              groupValue: taskType,
                              onChanged: (String value){ },
                            ),
                          ),
                        ),
                        onTap: () {
                          setState((){
                            taskType = "hw";
                          });
                        },
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8.0,),
                        child: IgnorePointer(
                          child: ListTile(
                            title: Text("Exam"),
                            leading: Radio<String>(
                              value: "exam",
                              groupValue: taskType,
                              onChanged: (String value){ },
                            ),
                          ),
                        ),
                        onTap: () {
                          setState((){
                            taskType = "exam";
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
                          if(selectedCourse==null){
                            showBasicDialog(context, "Must select course!");
                            return;
                          } else if(taskName==null){
                            showBasicDialog(context, "Task name cannot be empty!");
                            return;
                          } else if(dueDate==null){
                            showBasicDialog(context, "Task must have due date!");
                            return;
                          }
                          // if(selectedCourse==null||taskName==null||dueDate==null||taskType==null){
                          //   return;
                          // }
                          onConfirm(selectedCourse,taskName,dueDate,taskType);
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

    Widget taskCardMaker(int index, double cardWidth){
      var borderColor = sortedTaskList[index]['taskType']=='hw' ? Provider.of<UserDB>(context).mainColor : Colors.black;
      var buttonColor = sortedTaskList[index]['taskType']=='hw' ? Provider.of<UserDB>(context).secondaryColor : Colors.black;
      var hwData = sortedTaskList[index];
      var content = Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                trailing: remainingTimeBadge(index),
                leading: Icon(sortedTaskList[index]['taskType']=='hw' ? Icons.event_note : Icons.assignment_outlined),
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
                    timeDiff(index)>=0 ? "Due on "+DateFormat('MMM d, y').format(DateTime.fromMillisecondsSinceEpoch(hwData['due'])) : "DEADLINE PASSED",
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
                        onPressed: () => showHWDialog(hwData['courseName'], DateTime.fromMillisecondsSinceEpoch(hwData['due']), hwData['hwName'], hwData['taskType'],
                                (String cn, String tn, DateTime dt, String tt) => Provider.of<UserDB>(context,listen: false).editTask(hwData,cn, tn, dt, tt)),
                        child: Text('EDIT', style: TextStyle(color: buttonColor),)
                    ),
                    TextButton(
                        onPressed: (){
                          UserDB userDB = Provider.of<
                              UserDB>(
                              context,
                              listen: false);
                          userDB.completeHomework(index);
                          final snackBar = SnackBar(
                            content: Text("Homework marked as complete"),
                            action: SnackBarAction(
                              label: "UNDO",
                              onPressed: (){
                                userDB.undoCompleteHomework();
                              },
                            ),
                          );
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: Text(timeDiff(index)>=0 ? 'MARK AS COMPLETE' : 'ARCHIVE', style: TextStyle(color: buttonColor),)
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        // height: 100,
        decoration: BoxDecoration(
            border: Border(bottom:BorderSide(color: borderColor, width: 5) ,top: BorderSide(color: borderColor, width: 5))
        ),
      )
      ;
      return Container(
        width: cardWidth,
        child: Card(
          color: sortedTaskList[index]['taskType'] == 'hw' ? Colors.white : Colors.white,
          child: ClipPath(
            child: sortedTaskList[index]['taskType']=='hw' ? content : Banner(message: "EXAM", location: BannerLocation.topEnd, color: Colors.red, child: content,)            ,
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

    int hwCount = sortedTaskList.length;
    Widget taskContent(int listIndex) {
      int displayCount = max(0,min(hwCount-listIndex*horCount,horCount));
      return Container(
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: List.generate(
              displayCount,
                  (index) => taskCardMaker(listIndex*horCount + index,MediaQuery.of(context).size.width/horCount)
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
        children: List.generate(hwCount ~/ horCount + (hwCount%horCount>0 ? 1 : 0), (index) => Container(height: (MediaQuery.of(context).size.height-AppBar().preferredSize.height)/count,child: taskContent(index))),
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
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("No courses found. Add some in the Course Table tab!",style: TextStyle(fontSize: 24)),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Provider.of<UserDB>(context, listen: false).mainColor)
                ),
                onPressed: (){
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return NewCourseTableWidget();
                      },
                    ),
                  );
                },
                child: Text(
                  "View Course Table",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
            ),
          )
        ],
      );
    } else if (Provider.of<UserDB>(context).homeworkList.isEmpty) {
      content = Text("Click on the Plus button to add assignments!",style: TextStyle(fontSize: 24));
    } else {
      content = quadHome;
    }

    return Scaffold(
      appBar: taskyAppBar(context, "Assignments & Exams"),
      drawer: NavigationDrawer(),
      body: Center(child: content),
      floatingActionButton: Provider.of<UserDB>(context).courseOrder.isEmpty ? null : FloatingActionButton(
        backgroundColor: Provider.of<UserDB>(context, listen: false).mainColor,
        child: Icon(Icons.add),
        onPressed: (){
          showHWDialog(null, null, null, "hw",(String cn, String tn, DateTime dt, String tt) => Provider.of<UserDB>(context,listen: false).addHomework(cn, tn, dt, tt));
        },
      ),
    );
  }

}