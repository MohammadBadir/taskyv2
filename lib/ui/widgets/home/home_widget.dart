import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/app_bar/tasky_app_bar.dart';

import '../../../app/constants/strings.dart';
import '../../../app/services/firebase_auth_service.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key key}) : super(key: key);

  showMyDialog(BuildContext context, String message){
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


  @override
  Widget build(BuildContext context) {
    List pendingTaskList = Provider.of<UserDB>(context).pendingTaskList;
    double screenWidth = MediaQuery.of(context).size.width;
    double taskWidth = screenWidth > 2000 ? screenWidth/2 : (screenWidth > 1000 ? 1000 : screenWidth);

    return Scaffold(
      appBar: taskyAppBar(context, "Home"),
      drawer: NavigationDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  child: Text("Welcome back, "+Provider.of<UserDB>(context).displayName,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  child: Text("Your current tasks:",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
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
                                            fontSize: 36,
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
                                                                  showMyDialog(context, "Task cannot be empty!");
                                                                  return;
                                                                } if(oldTaskName!=newTaskName && pendingTaskList.contains(newTaskName)){
                                                                  showMyDialog(context, "Task already exists!");
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
                                            Provider.of<
                                                UserDB>(
                                                context,
                                                listen: false)
                                                .completePendingTask(index);
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
                                          color: Colors.blueAccent,
                                          width: 5),
                                      right: BorderSide(
                                          color: Colors.blueAccent,
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
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
                                showMyDialog(context, "Task cannot be empty!");
                                return;
                              } if(pendingTaskList.contains(taskName)){
                                showMyDialog(context, "Task already exists!");
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
