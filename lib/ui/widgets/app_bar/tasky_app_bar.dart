import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/constants/pages.dart';
import 'package:tasky/app/constants/themes.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/models/course_options.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/misc/basic_dialog.dart';

showSettingsDialog(BuildContext context){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        String oldCourseName = "hi";
        String newCourseName = oldCourseName;
        int lecCount = 0;
        int tutCount = 0;
        int wrkCount = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  " Settings"
              ),
              content: Column(
                mainAxisSize: MainAxisSize
                    .min,
                crossAxisAlignment: CrossAxisAlignment
                    .start,
                children: [
                  Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height / 3,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width / 2.7,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(" Username:",
                                  style: TextStyle(color: Colors.grey),),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                                  child: ElevatedButton(onPressed: (){
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          String taskName;
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                title: Center(
                                                  child: Text(
                                                      "Enter Username"
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
                                                      Navigator.of(
                                                          context).pop();
                                                    },
                                                    child: Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        if (taskName == null || taskName=="") {
                                                          showBasicDialog(context, "Username cannot be empty!");
                                                          return;
                                                        }
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
                                                      child: Text(
                                                          "Confirm")
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                    );
                                  }, child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(Provider.of<UserDB>(context, listen: false).displayName, style: TextStyle(fontSize: 24.0),),
                                  )),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(" Default Page:",
                                  style: TextStyle(color: Colors.grey),),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: List.generate(Pages.pageNames.length, (index) => (Provider.of<UserDB>(context, listen: false).defaultPage==index) ? ElevatedButton(
                                    onPressed: (){},
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Text(Pages.pageNames[index]),
                                    ),
                                  ): TextButton(
                                    onPressed: () => Provider.of<UserDB>(context, listen: false).changeDefaultPage(index),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Text(Pages.pageNames[index]),
                                    ),
                                  )),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(" Theme:",
                                  style: TextStyle(color: Colors.grey),),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: List.generate(Themes.colorPalletes.length,
                                            (index) => Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: IconButton(onPressed: () => Provider.of<UserDB>(context, listen: false).changeTheme(index), icon: Icon(Icons.circle, color: Themes.colorPalletes[index]['main'],)),
                                        )),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      // child: Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Column(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Padding(
                      //             padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                      //             child: Text(" Username:",
                      //               style: TextStyle(color: Colors.grey),),
                      //           ),
                      //           Padding(
                      //             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      //             child: Text(" Default Page:",
                      //               style: TextStyle(color: Colors.grey),),
                      //           ),
                      //           Padding(
                      //             padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                      //             child: Text(" Theme:",
                      //               style: TextStyle(color: Colors.grey),),
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      //     Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Column(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           Padding(
                      //             padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                      //             child: TextButton(onPressed: (){}, child: Text(Provider.of<UserDB>(context, listen: false).displayName, style: TextStyle(fontSize: 24.0),)),
                      //           ),
                      //           Padding(
                      //             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.end,
                      //               children: Pages.pageNames.map((e) => TextButton(
                      //                 onPressed: (){},
                      //                 child: Padding(
                      //                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      //                   child: Text(e),
                      //                 ),
                      //               )).toList(),
                      //             ),
                      //           ),
                      //           Padding(
                      //             padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.end,
                      //               children: List.generate(Themes.colorPalletes.length,
                      //                       (index) => Padding(
                      //                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      //                     child: IconButton(onPressed: () => Provider.of<UserDB>(context, listen: false).changeTheme(index), icon: Icon(Icons.circle, color: Themes.colorPalletes[index]['main'],)),
                      //                   )),
                      //             ),
                      //           )
                      //
                      //         ],
                      //       ),
                      //     )
                      //   ],
                      // ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Done"),
                    )
                ),
              ],
            );
          },
        );
      }
  );
}

Widget taskyAppBar(context, String title){
  //TODO: this whole file is a mess, needs to tidied and replaced with a proper class
  int selectedSemester = Provider.of<UserDB>(context).currentSemester;
  return AppBar(
    backgroundColor: Provider.of<UserDB>(context).mainColor,
    title: Center(child: Text(title)),
    actions: MediaQuery.of(context).size.width<950 ? [] : [
      // DropdownButton(
      //   value: selectedSemester,
      //   items: Provider.of<UserDB>(context).semesterOrder.map((var x) => DropdownMenuItem(child: Text(x),value: Provider.of<UserDB>(context).semesterOrder.indexOf(x),)).toList() + [DropdownMenuItem(child: Text("Add Semester"), value: -1)],
      //   onChanged: (var x){
      //     if(x==-1){
      //       //addsemester
      //     } else {
      //       Provider.of<UserDB>(context, listen: false).changeSemester(x);
      //     }
      //   },
      // ),
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).scaffoldBackgroundColor),
            foregroundColor: MaterialStateProperty.all<Color>(Provider.of<UserDB>(context).mainColor)
          ),
          onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context){
                  return StatefulBuilder(
                    builder: (context, setState){
                      return AlertDialog(
                        title: Center(child: Text("All Semesters")),
                        content: Container(
                          width: MediaQuery.of(context).size.width/3,
                          child: ListView(
                            shrinkWrap: true,
                            children: List.generate(
                                Provider.of<UserDB>(context, listen: false).semesterOrder.length,
                                    (index) => Container(
                                  key: UniqueKey(),
                                  height: 50,
                                  child: Card(
                                    color: Colors.white,
                                    child: ClipPath(
                                      child: Container(
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8.0),
                                                  child: Text(Provider.of<UserDB>(context, listen: false).semesterOrder[index],
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: Provider.of<UserDB>(context, listen: false).semesterOrder[index].length < 20 ? 16 : 14,
                                                        fontWeight: FontWeight
                                                            .bold),),
                                                ),
                                                Row(
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (
                                                                BuildContext context) {
                                                              return StatefulBuilder(
                                                                builder: (context,
                                                                    setState) {
                                                                  if(Provider.of<UserDB>(context, listen: false).currentSemester==index){
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          "Cannot delete current semester"),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop();
                                                                          },
                                                                          child: Text(
                                                                              "OK"),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        "Are you sure you want to delete this semester?"),
                                                                    content: Text(
                                                                        "This action cannot be undone"),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          Provider.of<UserDB>(context, listen: false).deleteSemester(index);
                                                                          Navigator
                                                                              .of(
                                                                              context)
                                                                              .pop();
                                                                        },
                                                                        child: Text(
                                                                            "Yes"),
                                                                      ),
                                                                      TextButton(
                                                                          onPressed: () {
                                                                            Navigator
                                                                                .of(
                                                                                context)
                                                                                .pop();
                                                                          },
                                                                          child: Text(
                                                                              "No")
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            }
                                                        );
                                                      },
                                                      child: Text("DELETE",
                                                        style: TextStyle(
                                                            color: Colors.red),),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              String semesterName;
                                                              return StatefulBuilder(
                                                                builder: (context, setState) {
                                                                  return AlertDialog(
                                                                    title: Center(
                                                                      child: Text(
                                                                          "Enter Semester Name"
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
                                                                              initialValue: Provider.of<UserDB>(context, listen: false).semesterOrder[index],
                                                                              decoration: InputDecoration(
                                                                                  labelText: " Semester Name",
                                                                                  hintText: "e.g. Spring 2022"
                                                                              ),
                                                                              onChanged: (
                                                                                  String str) {
                                                                                semesterName = str;
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
                                                                            if (semesterName == null || semesterName=="") {
                                                                              showBasicDialog(context, "Semester Name cannot be empty!");
                                                                              return;
                                                                            }
                                                                            Provider.of<
                                                                                UserDB>(
                                                                                context,
                                                                                listen: false)
                                                                                .renameSemester(index, semesterName);
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
                                                    Padding(
                                                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Provider.of<UserDB>(context, listen: false).changeSemester(index);
                                                        },
                                                        child: Text(index == Provider.of<UserDB>(context, listen: false).currentSemester ? "SELECTED" : "SELECT",
                                                          style: TextStyle(
                                                              color: Colors.green),),
                                                      ),
                                                    ),
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
                                )
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      String semesterName;
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: Center(
                                              child: Text(
                                                  "Enter Semester Name"
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
                                                          labelText: " Semester Name",
                                                          hintText: "e.g. Spring 2022"
                                                      ),
                                                      onChanged: (
                                                          String str) {
                                                        semesterName = str;
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
                                                    if (semesterName == null || semesterName=="") {
                                                      showBasicDialog(context, "Username cannot be empty!");
                                                      return;
                                                    }
                                                    Provider.of<UserDB>(context, listen: false).addSemester(semesterName);
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Add Semester"),
                              )
                          ),
                          TextButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text("Done"),
                              )
                          ),
                        ],
                      );
                    },
                  );
                }
            );
          },
          child: Text(Provider.of<UserDB>(context).semesterOrder[Provider.of<UserDB>(context).currentSemester], style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ),
      IconButton(onPressed: (){
        showSettingsDialog(context);
      }, icon: Icon(Icons.settings))
    ],
  );
}