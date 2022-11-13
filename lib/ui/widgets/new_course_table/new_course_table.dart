import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/constants/strings.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/models/course_options.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/app_bar/tasky_app_bar.dart';
import 'package:tasky/ui/widgets/misc/basic_dialog.dart';
import 'package:tasky/ui/widgets/misc/screen_too_small.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:tasky/ui/widgets/new_course_table/widgets/card_wrapper.dart';
import 'package:tasky/ui/widgets/new_course_table/widgets/course_card.dart';
import 'package:tasky/ui/widgets/new_course_table/widgets/table_buttons.dart';
import 'package:tasky/ui/widgets/new_course_table/widgets/week_bar.dart';

import 'no_courses.dart';

class NewCourseTableWidget extends StatefulWidget {
  @override
  _NewCourseTableWidgetState createState() => _NewCourseTableWidgetState();
}

class _NewCourseTableWidgetState extends State<NewCourseTableWidget> {

  @override
  Widget build(BuildContext context) {
    UserDB userDB = Provider.of<UserDB>(context);

    List courseOrder = userDB.courseOrder;
    Map courseProgressMap = userDB.courseProgressMap;
    Color mainColor = userDB.mainColor;
    Color secondaryColor = userDB.secondaryColor;

    //courseProgressMap.forEach((key, value) { print(MapEntry(key, value)); });

    List<Widget> courseCardList = [];
    courseOrder.forEach((courseName) {
      if(!userDB.isHiddenCourse(courseName)){
        courseCardList.add(CourseCard(courseName, courseProgressMap[courseName], mainColor: mainColor));
      }
    });
    //courseCardList.add(Text(MediaQuery.of(context).size.width.toString()));
    ListView courseCardListView = ListView(
      children: courseCardList,
    );

    List<String> dialogOptions = [
      "Weekly Lecture Count:",
      "Weekly Tutorial Count:",
      "Weekly Workshop Count:"
    ];

    return Scaffold(
      appBar: taskyAppBar(context, "Course Table"),
      drawer: NavigationDrawer(),
      body: MediaQuery.of(context).size.width>=950 ? (courseOrder.isEmpty ? NoCoursesWidget() : Column(
        children: [
          WeekBar(),
          Expanded(
            child: courseCardListView,
          ),
          //TableButtons()
        ],
      )) : ScreenTooSmallWidget(),
      floatingActionButton: MediaQuery.of(context).size.width<950 ? null : FloatingActionButton.extended(
        label: Text("EDIT"),
        icon: /*Provider.of<UserDB>(context).editMode ? Icon(Icons.check_rounded, size: 35.0,) :*/ Icon(Icons.edit),
        backgroundColor: mainColor,
        onPressed: (){
          // Provider.of<UserDB>(context, listen: false).standardUpdateAllCourses();
          // return;
          showDialog(
              context: context,
              builder: (BuildContext context){
                return StatefulBuilder(
                  builder: (context, setState){
                    int totalLectures = 0;
                    courseProgressMap.forEach((key, value) { totalLectures+= value["info"]["lectureCount"]; });
                    int totalTutorials = 0;
                    courseProgressMap.forEach((key, value) { totalTutorials+= value["info"]["tutorialCount"]; });
                    int totalWorkshops = 0;
                    courseProgressMap.forEach((key, value) { totalWorkshops+= value["info"]["workshopCount"]; });
                    return AlertDialog(
                      title: Center(child: Text(
                          (courseOrder.isNotEmpty ? courseOrder.length.toString() : "No") + " Course" + (courseOrder.length!=1 ? "s" : "") + (courseOrder.isNotEmpty ? " - " : "") +
                              (totalLectures>0 ? totalLectures.toString() + (" Lecture" + (totalLectures!=1 ? "s" : "")) : "") +
                              (totalTutorials>0 ? (totalLectures>0 ? ", " : "") + totalTutorials.toString() + (" Tutorial" + (totalTutorials!=1 ? "s" : "")) : "") +
                              (totalWorkshops>0 ? (totalLectures>0 || totalTutorials>0 ? ", " : "") + totalWorkshops.toString() + (" Workshop" + (totalWorkshops!=1 ? "s" : "")) : "")
                      )),
                      content: Container(
                        width: MediaQuery.of(context).size.width/3,
                        child: ReorderableListView(
                          buildDefaultDragHandles: false,
                          shrinkWrap: true,
                          children: List.generate(
                              courseOrder.length,
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
                                                child: Text(courseOrder[index],
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontSize: courseOrder[index].length < 20 ? 16 : 14,
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
                                                            String oldCourseName = courseOrder[index];
                                                            String newCourseName = oldCourseName;
                                                            var courseOptions = CourseOptions.fromInfoMap(courseProgressMap[oldCourseName]["info"]);
                                                            int lecCount = courseOptions.lectureCount;
                                                            int tutCount = courseOptions.tutorialCount;
                                                            int wrkCount = courseOptions.workShopCount;
                                                            return StatefulBuilder(
                                                              builder: (context, setState) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      " Edit Course Details"
                                                                  ),
                                                                  content: Column(
                                                                    mainAxisSize: MainAxisSize
                                                                        .min,
                                                                    crossAxisAlignment: CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      Container(
                                                                        height: 180,
                                                                        width: MediaQuery
                                                                            .of(context)
                                                                            .size
                                                                            .width / 2.7,
                                                                        child: ListView
                                                                            .builder(
                                                                            shrinkWrap: true,
                                                                            itemCount: 3,
                                                                            itemBuilder: (
                                                                                BuildContext context,
                                                                                int index) {
                                                                              return Padding(
                                                                                padding: const EdgeInsets.all(16.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text(" "+dialogOptions[index],
                                                                                      style: TextStyle(color: Colors.grey),),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        TextButton(onPressed: () { setState((){
                                                                                          switch(index){
                                                                                            case 0:{
                                                                                              if(lecCount>0) lecCount--;
                                                                                            }
                                                                                            break;
                                                                                            case 1:{
                                                                                              if(tutCount>0) tutCount--;
                                                                                            }
                                                                                            break;
                                                                                            case 2:{
                                                                                              if(wrkCount>0) wrkCount--;
                                                                                            }
                                                                                            break;
                                                                                          }
                                                                                        }); },
                                                                                            child: Icon(Icons.arrow_back_ios_new)),
                                                                                        Text(" "+(index==0 ? lecCount : index==1 ? tutCount : wrkCount).toString()+" "),
                                                                                        TextButton(onPressed: () { setState((){
                                                                                          switch(index){
                                                                                            case 0:{
                                                                                              if(lecCount<2) lecCount++;
                                                                                            }
                                                                                            break;
                                                                                            case 1:{
                                                                                              if(tutCount<2) tutCount++;
                                                                                            }
                                                                                            break;
                                                                                            case 2:{
                                                                                              if(wrkCount<2) wrkCount++;
                                                                                            }
                                                                                            break;
                                                                                          }
                                                                                        }); },
                                                                                            child: Icon(Icons.arrow_forward_ios))                                                              ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                                                                        child: TextFormField(
                                                                          decoration: InputDecoration(
                                                                            labelText: " Course Name",
                                                                              hintText: "e.g. Calculus 1m"
                                                                          ),
                                                                          initialValue: oldCourseName,
                                                                          onChanged: (
                                                                              String str) {
                                                                            newCourseName = str;
                                                                          },
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
                                                                          if (newCourseName == null || newCourseName=="") {
                                                                            showBasicDialog(context, "Course must have a name!");
                                                                            return;
                                                                          } else if(lecCount+tutCount+wrkCount==0){
                                                                            showBasicDialog(context, "Course cannot be empty!");
                                                                            return;
                                                                          } else if(oldCourseName!=newCourseName && courseOrder.contains(newCourseName)){
                                                                            showBasicDialog(context, "Course already exists!");
                                                                            return;
                                                                          }
                                                                          CourseOptions newCourseOptions = CourseOptions();
                                                                          newCourseOptions.lectureCount = lecCount;
                                                                          newCourseOptions.tutorialCount = tutCount;
                                                                          newCourseOptions.workShopCount = wrkCount;
                                                                          Provider.of<
                                                                              UserDB>(
                                                                              context,
                                                                              listen: false)
                                                                              .editCourse(oldCourseName, newCourseName, newCourseOptions);
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
                                                      showDialog(
                                                          context: context,
                                                          builder: (
                                                              BuildContext context) {
                                                            return StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      "Are you sure you want to delete this course?"),
                                                                  content: Text(
                                                                      "This action cannot be undone"),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        Provider
                                                                            .of<
                                                                            UserDB>(
                                                                            context,
                                                                            listen: false)
                                                                            .deleteCourse(index);
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
                                                      userDB.toggleHideCourse(courseOrder[index]);
                                                    },
                                                    child: Text(userDB.isHiddenCourse(courseOrder[index]) ? "UNHIDE" : "HIDE",
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
                                                    color: mainColor,
                                                    width: 5),
                                                right: BorderSide(
                                                    color: mainColor,
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
                          onReorder: (int oldIndex, int newIndex) {
                            Provider.of<UserDB>(context, listen: false).swapCourseOrder(newIndex, oldIndex);
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: (){
                              showDialog(
                                  context: context,
                                  builder: (
                                      BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (context,
                                          setState) {
                                        return AlertDialog(
                                          title: Text(
                                              "Are you sure you want to delete all courses?"),
                                          content: Text(
                                              "This action cannot be undone"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Provider
                                                    .of<
                                                    UserDB>(
                                                    context,
                                                    listen: false)
                                                    .deleteAllCourses();
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("Delete All Courses", style: TextStyle(color: Colors.red),),
                            )
                        ),
                        TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String courseName;
                                    int lecCount=1;
                                    int tutCount=1;
                                    int wrkCount=0;
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: Text(
                                              " Enter Course Details"
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize
                                                .min,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Container(
                                                height: 180,
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width / 3,
                                                child: ListView
                                                    .builder(
                                                    shrinkWrap: true,
                                                    itemCount: 3,
                                                    itemBuilder: (
                                                        BuildContext context,
                                                        int index) {
                                                      return Padding(
                                                        padding: const EdgeInsets.all(16.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(" "+dialogOptions[index],
                                                            style: TextStyle(color: Colors.grey),),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                TextButton(onPressed: () { setState((){
                                                                  switch(index){
                                                                    case 0:{
                                                                      if(lecCount>0) lecCount--;
                                                                    }
                                                                    break;
                                                                    case 1:{
                                                                      if(tutCount>0) tutCount--;
                                                                    }
                                                                    break;
                                                                    case 2:{
                                                                      if(wrkCount>0) wrkCount--;
                                                                    }
                                                                    break;
                                                                  }
                                                                }); },
                                                                    child: Icon(Icons.arrow_back_ios_new)),
                                                                Text(" "+(index==0 ? lecCount : index==1 ? tutCount : wrkCount).toString()+" "),
                                                                TextButton(onPressed: () { setState((){
                                                                  switch(index){
                                                                    case 0:{
                                                                      if(lecCount<2) lecCount++;
                                                                    }
                                                                    break;
                                                                    case 1:{
                                                                      if(tutCount<2) tutCount++;
                                                                    }
                                                                    break;
                                                                    case 2:{
                                                                      if(wrkCount<2) wrkCount++;
                                                                    }
                                                                    break;
                                                                  }
                                                                }); },
                                                                    child: Icon(Icons.arrow_forward_ios))                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                                                child: TextFormField(
                                                  decoration: InputDecoration(
                                                    labelText: " Course Name",
                                                    hintText: "e.g. Calculus 1m"
                                                  ),
                                                  onChanged: (
                                                      String str) {
                                                    courseName = str;
                                                  },
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
                                                  if (courseName == null || courseName=="") {
                                                    showBasicDialog(context, "Course must have a name!");
                                                    return;
                                                  } else if(lecCount+tutCount+wrkCount==0){
                                                    showBasicDialog(context, "Course cannot be empty!");
                                                    return;
                                                  } else if(courseOrder.contains(courseName)){
                                                    showBasicDialog(context, "Course already exists!");
                                                    return;
                                                  }
                                                  CourseOptions courseOptions = CourseOptions();
                                                  courseOptions.lectureCount = lecCount;
                                                  courseOptions.tutorialCount = tutCount;
                                                  courseOptions.workShopCount = wrkCount;
                                                  Provider.of<
                                                      UserDB>(
                                                      context,
                                                      listen: false)
                                                      .addCourse(
                                                      courseName,
                                                      courseOptions);
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
                              child: Text("Add Course"),
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
      ),
    );
  }
}