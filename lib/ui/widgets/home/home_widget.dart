import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/app_bar/tasky_app_bar.dart';
import 'package:tasky/ui/widgets/misc/basic_dialog.dart';
import 'package:tasky/ui/widgets/misc/screen_too_small.dart';

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

    return Scaffold(
      appBar: taskyAppBar(context, "Home"),
      drawer: NavigationDrawer(),
      body: MediaQuery.of(context).size.width<950 ? ScreenTooSmallWidget() : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: noTasks ? [
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
              flex: 4,
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
          ] : [
            Expanded(
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
            Expanded(
              child: Center(
                child: Container(
                  child: Text("Your current tasks:",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Provider.of<UserDB>(context, listen: false).secondaryColor
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
          ]
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
