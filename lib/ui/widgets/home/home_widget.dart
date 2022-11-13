import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/app_bar/tasky_app_bar.dart';
import 'package:tasky/ui/widgets/misc/basic_dialog.dart';
import 'package:tasky/ui/widgets/misc/screen_too_small.dart';

import '../homework_table/task_table.dart';
import '../new_course_table/new_course_table.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(Provider.of<UserDB>(context, listen: false).firstTime){
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              String taskName;
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Center(
                      child: Text(
                          "Welcome to Tasky! Please enter a username"
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize
                          .min,
                      crossAxisAlignment: CrossAxisAlignment
                          .start,
                      children: [
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 4,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                            child: TextFormField(
                              initialValue: Provider.of<UserDB>(context, listen: false).displayName,
                              decoration: InputDecoration(
                                  labelText: " Username",
                                  hintText: "e.g. Adam"
                              ),
                              onChanged: (
                                  String str) {
                                taskName = str;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            if (taskName == null || taskName=="") {
                              showBasicDialog(context, "Username cannot be empty!");
                              return;
                            }
                            Provider.of<
                                UserDB>(
                                context,
                                listen: false).firstTime = false;
                            Provider.of<
                                UserDB>(
                                context,
                                listen: false)
                                .changeUsername(
                                taskName);
                            Navigator.of(
                                context)
                                .pop();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    List pendingTaskList = Provider.of<UserDB>(context).pendingTaskList;
    double screenWidth = MediaQuery.of(context).size.width;
    double taskWidth = screenWidth > 2000 ? screenWidth/2 : (screenWidth > 1000 ? 1000 : screenWidth);
    bool noTasks = pendingTaskList.isEmpty;

    var noTasksWidgets = [
      Expanded(
        flex: 10,
        child: Center(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("You have no pending tasks",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Provider.of<UserDB>(context, listen: false).secondaryColor
                  ),
                ),
                Container(height: 40,),
                Text("Add some by clicking the plus button",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Provider.of<UserDB>(context, listen: false).secondaryColor
                  ),
                )
              ],
            ),
          ),
        ),
      )
    ];

    int horCount;
    for(horCount=6; horCount>0; --horCount){
      if(MediaQuery.of(context).size.width/horCount>=300){
        break;
      }
    }

    var currentTime = DateTime.now();
    int daysBetween(DateTime from, DateTime to) {
      from = DateTime(from.year, from.month, from.day);
      to = DateTime(to.year, to.month, to.day);
      return (to.difference(from).inHours / 24).round();
    }
    double cardListWidth = taskWidth - 100;
    double courseCardWidth = cardListWidth/3;
    List sortedTaskList = List.from(Provider.of<UserDB>(context).homeworkList.where((element) => daysBetween(currentTime, DateTime.fromMillisecondsSinceEpoch(element['due']))>=0));
    sortedTaskList.sort((var a, var b) => a['due'].compareTo(b['due']));

    Widget taskCardMaker(int index, double cardWidth){
      var borderColor = Provider.of<UserDB>(context).mainColor;
      var buttonColor = Provider.of<UserDB>(context).secondaryColor;
      var hwData = sortedTaskList[index];
      var userDb = Provider.of<UserDB>(context);
      int timeDiff(int index) {
        return daysBetween(currentTime, DateTime.fromMillisecondsSinceEpoch(sortedTaskList[index]['due']));
      }
      int timeLeft = timeDiff(index);
      var content = Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(sortedTaskList[index]['taskType']=='hw' ? Icons.event_note : Icons.assignment_outlined),
                title: Text(
                  hwData['courseName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(hwData['hwName']),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  timeLeft>0 ? "Due in " + timeDiff(index).toString() + " day" + (timeDiff(index)>1 ? "s" : "") : "Due Today!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              )
            ],
          ),
        ),
        // height: 100,
        decoration: BoxDecoration(
            border: Border(bottom:BorderSide(color: borderColor, width: 5) ,top: BorderSide(color: borderColor, width: 5))
        ),
      );

      return Container(
        width: cardWidth,
        child: Card(
          color: Colors.white,
          child: ClipPath(
            child: content,
            clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3))),
          ),
        ),
      );
    }
    int numOfCoursesToShow = min(3, sortedTaskList.length);

    return Scaffold(
      appBar: taskyAppBar(context, "Home"),
      drawer: NavigationDrawer(),
      body: MediaQuery.of(context).size.width<950 || MediaQuery.of(context).size.height<600 ? ScreenTooSmallWidget() : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  child: Text(Provider.of<UserDB>(context, listen: false).firstTime ? "Welcome!" : "Welcome back, "+Provider.of<UserDB>(context).displayName,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            numOfCoursesToShow==0 ? Container() : SizedBox(
              height: 160,
              child: Center(
                child: Container(
                  width: cardListWidth * (numOfCoursesToShow/3),
                  child: Row(
                    children: List.generate(
                        numOfCoursesToShow,
                            (index) => taskCardMaker(index, courseCardWidth)
                    ),
                  ),
                ),
              ),
            ),
            numOfCoursesToShow==0 ? Container() : Expanded(child: Container()),
            numOfCoursesToShow==0 ? Container() : Row(
              children: [
                Expanded(flex: 9, child: Container()),
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
                ),
                Expanded(child: Container()),
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
                              return TaskWidget();
                            },
                          ),
                        );
                      },
                      child: Text(
                        "View All Assignments",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                  ),
                ),
                Expanded(flex: 9, child: Container())
              ],
            ),
          ]
              +
          (noTasks ? noTasksWidgets : [
            Expanded(child: Container()),
            Container(
              child: Text("Your current tasks:",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Provider.of<UserDB>(context, listen: false).secondaryColor
                ),
              ),
            ),
            Expanded(child: Container()),
            Expanded(
              flex: 10,
              child: Container(
                width: taskWidth,
                child: ReorderableListView(
                    buildDefaultDragHandles: false,
                    shrinkWrap: true,
                    children: List.generate(pendingTaskList.length, (index) => Container(
                      height: 60,
                      key: UniqueKey(),
                      child: Card(
                        color: Colors.white,
                        child: ClipPath(
                          child: Container(
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Container(),
                                    Padding(
                                      padding: const EdgeInsets
                                          .symmetric(horizontal: 8.0),
                                      child: Text(pendingTaskList[index],
                                        style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight
                                                .bold),),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  String oldTaskName = pendingTaskList[index];
                                                  String newTaskName = oldTaskName;
                                                  return StatefulBuilder(
                                                    builder: (context, setState) {
                                                      return AlertDialog(
                                                        title: Center(
                                                          child: Text(
                                                              "Edit Task Name"
                                                          ),
                                                        ),
                                                        content: Column(
                                                          mainAxisSize: MainAxisSize
                                                              .min,
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            Container(
                                                              width: MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width / 4,
                                                              child: Padding(
                                                                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                                                                child: TextFormField(
                                                                  decoration: InputDecoration(
                                                                    labelText: " Task Name",
                                                                  ),
                                                                  initialValue: oldTaskName,
                                                                  onChanged: (
                                                                      String str) {
                                                                    newTaskName = str;
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                  context).pop();
                                                            },
                                                            child: Text("Cancel"),
                                                          ),
                                                          TextButton(
                                                              onPressed: () {
                                                                if (newTaskName == null || newTaskName=="") {
                                                                  showBasicDialog(context, "Task cannot be empty!");
                                                                  return;
                                                                } if(oldTaskName!=newTaskName && pendingTaskList.contains(newTaskName)){
                                                                  showBasicDialog(context, "Task already exists!");
                                                                  return;
                                                                }
                                                                Provider.of<
                                                                    UserDB>(
                                                                    context,
                                                                    listen: false)
                                                                    .editPendingTask(
                                                                    oldTaskName,
                                                                    newTaskName);
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  "Confirm")
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                            );
                                          },
                                          child: Text("EDIT"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            UserDB userDB = Provider.of<
                                                UserDB>(
                                                context,
                                                listen: false);
                                            userDB.completePendingTask(index);
                                            final snackBar = SnackBar(
                                              content: Text("Task marked as complete"),
                                              action: SnackBarAction(
                                                label: "UNDO",
                                                onPressed: (){
                                                  userDB.undoCompletePendingTask();
                                                },
                                              ),
                                            );
                                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          },
                                          child: Text("COMPLETE",
                                            style: TextStyle(
                                                color: Colors.green),),
                                        ),
                                        ReorderableDragStartListener(
                                          index: index,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                                            child: Icon(Icons.drag_handle),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                          color: Provider.of<UserDB>(context, listen: false).mainColor,
                                          width: 5),
                                      right: BorderSide(
                                          color: Provider.of<UserDB>(context, listen: false).mainColor,
                                          width: 5)))
                          ),
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      3))),
                        ),
                      ),
                    )),
                    onReorder: (int oldIndex, int newIndex) {
                      Provider.of<UserDB>(context, listen: false).swapPendingTaskOrder(newIndex, oldIndex);
                    }
                    ),
              ),
            )
          ])
        ),
      ),
      floatingActionButton: MediaQuery.of(context).size.width<950 ? null : FloatingActionButton(
        backgroundColor: Provider.of<UserDB>(context, listen: false).mainColor,
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                String taskName;
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Center(
                        child: Text(
                            "Enter Task Name"
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize
                            .min,
                        crossAxisAlignment: CrossAxisAlignment
                            .start,
                        children: [
                          Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width / 4,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: " Task Name",
                                  hintText: "e.g. Catching up on Calculus"
                                ),
                                onChanged: (
                                    String str) {
                                  taskName = str;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(
                                context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                            onPressed: () {
                              if (taskName == null || taskName=="") {
                                showBasicDialog(context, "Task cannot be empty!");
                                return;
                              } if(pendingTaskList.contains(taskName)){
                                showBasicDialog(context, "Task already exists!");
                                return;
                              }
                              Provider.of<
                                  UserDB>(
                                  context,
                                  listen: false)
                                  .addPendingTask(
                                  taskName);
                              Navigator.of(
                                  context)
                                  .pop();
                            },
                            child: Text(
                                "Confirm")
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
