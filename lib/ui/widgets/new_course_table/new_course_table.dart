import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/constants/strings.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/models/course_options.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/new_course_table/screen_too_small.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'no_courses.dart';

class NewCourseTableWidget extends StatefulWidget {
  @override
  _NewCourseTableWidgetState createState() => _NewCourseTableWidgetState();
}

class _NewCourseTableWidgetState extends State<NewCourseTableWidget> {
  Widget cardMaker(Widget content, double cardHeight,
      {bool includeBorders = false}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: cardHeight,
      child: Card(
        color: Colors.white,
        child: ClipPath(
          child: Container(
            child: content,
            decoration: includeBorders
                ? BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.blueAccent, width: 5),
                        top: BorderSide(color: Colors.blueAccent, width: 5)))
                : null,
          ),
          clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3))),
        ),
      ),
    );
  }

  T cast<T>(x) => x is T ? x : null;

  @override
  Widget build(BuildContext context) {
    List courseOrder = Provider.of<UserDB>(context).courseOrder;
    Map courseProgressMap = Provider.of<UserDB>(context).courseProgressMap;

    //courseProgressMap.forEach((key, value) { print(MapEntry(key, value)); });

    Widget weekRow = Container(
      color: Colors.green,
      child: Row(
        children: List.generate(
            31,
            (index) => index % 2 == 0
                ? Container(
                    width: index==2 ? 0 : 5,
                    color: Colors.blueAccent,
                  )
                : Expanded(
                    child: Container(
                      child: Center(
                          child: index == 3
                              ? null
                              : Text(
                                  index == 1
                                      ? "Course"
                                      : (index ~/ 2 - 1).toString(),
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                )),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white),
                    ),
                    flex: index == 1 ? 9 : (index == 3 ? 0 : 2),
                  )),
      ),
    );

    List<Widget> listContent = [];
    courseOrder.forEach((courseName) {
      listContent.add(courseCard(courseName, courseProgressMap[courseName]));
    });
    listContent.add(Text(MediaQuery.of(context).size.width.toString()));

    List<String> dialogOptions = [
      "Weekly Lecture Count:",
      "Weekly Tutorial Count:",
      "Weekly Workshop Count:"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(Strings.newCourseTableTitle)),
      ),
      drawer: NavigationDrawer(),
      body: MediaQuery.of(context).size.width>=950 ? (courseOrder.isEmpty ? NoCoursesWidget() : Column(
        children: [
          cardMaker(weekRow, 50, includeBorders: true),
          Expanded(
            child: ListView(
              children: listContent,
            ),
          ),
        ],
      )) : ScreenTooSmallWidget(),
      floatingActionButton: MediaQuery.of(context).size.width<950 ? null : FloatingActionButton(
        child: /*Provider.of<UserDB>(context).editMode ? Icon(Icons.check_rounded, size: 35.0,) :*/ Icon(Icons.edit),
        backgroundColor: Colors.blueAccent,
        onPressed: (){
          showDialog(
              context: context,
              builder: (BuildContext context){
                return StatefulBuilder(
                  builder: (context, setState){
                    return AlertDialog(
                      title: Center(child: Text(courseOrder.length.toString() + " Courses")),
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
                                                      fontSize: 16,
                                                      fontWeight: FontWeight
                                                          .bold),),
                                              ),
                                              Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () {

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
                                                                        String courseName = courseOrder[index];
                                                                        courseOrder
                                                                            .removeAt(
                                                                            index);
                                                                        courseProgressMap
                                                                            .remove(
                                                                            courseName);
                                                                        Provider
                                                                            .of<
                                                                            UserDB>(
                                                                            context,
                                                                            listen: false)
                                                                            .updateCourses();
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
                              )
                          ),
                          onReorder: (int oldIndex, int newIndex) {
                            Provider.of<UserDB>(context, listen: false).swapCourseOrder(newIndex, oldIndex);
                          },
                        ),
                      ),
                      actions: [
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
                                                  if (courseName ==
                                                      null) {
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

  Widget courseCard(String courseName, Map courseMap) {
    int numRows = courseMap['data'].length;
    //List<String> names = ["Lecture #1"];
    VerticalDivider indexNeedsDivider(int index) =>
        index == 0 || index == 2 || index == 30 ? null : VerticalDivider(color: Colors.black38,);
    int flexByIndex(int index) => index == 1 ? 6 : (index == 3 ? 3 : 2);

    return cardMaker(
        Row(
          children: List.generate(
              31,
              (index) => index.isEven
                  ? Container(
                      width: index==2 ? 0 : 5,
                      color: Colors.white,
                      child: indexNeedsDivider(index))
                  : Expanded(
                      child: Container(
                        child: Center(
                            child: index == 1
                                ? Text(
                                    courseName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  )
                                : courseColumn(index, courseMap, courseName)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      flex: flexByIndex(index),
                    )),
        ),
        50.0*numRows,
        includeBorders: true);
  }

  CourseOptions courseOptionsFromData(Map courseInfo){
    CourseOptions options = CourseOptions();
    options.lectureCount = courseInfo['lectureCount'];
    options.tutorialCount = courseInfo['tutorialCount'];
    options.workShopCount = courseInfo['workshopCount'];
    if(options.lectureCount + options.tutorialCount + options.workShopCount == 0) {
      options.isSingleton = true;
    }
    return options;
  }

  Column courseColumn(int index, Map courseMap, String courseName) {
    int numWeeks = 13;
    CourseOptions courseOptions = courseOptionsFromData(courseMap['info']);
    Map courseData = courseMap['data'];
    int numRows = courseData.length;

    Widget press({String label, String fieldName, int count = 1}) {
      Widget iconToPut;
      if(courseData[fieldName].contains((index-3)~/2)){
        iconToPut = FittedBox(fit: BoxFit.fitHeight, child: Icon(Icons.check_rounded));
      } else if(count==2 && courseData[fieldName].contains((index-3)~/2 + numWeeks)){
        iconToPut = FittedBox(fit: BoxFit.fitHeight, child: Icon(Icons.done_all_rounded));
      } else if(courseData[fieldName].contains(-(index-3)~/2)){
        iconToPut = FittedBox(fit: BoxFit.scaleDown, child: Icon(Icons.circle,color: Colors.grey,));
      }

      return Expanded(
        child: InkWell(
            onTap: index == 3 ? null : () {
              if(courseData[fieldName].contains((index-3)~/2)){
                courseData[fieldName].remove((index-3)~/2);
                if(count==2) courseData[fieldName].add((index-3)~/2 + numWeeks);
              } else if(courseData[fieldName].contains((index-3)~/2 + numWeeks)){
                courseData[fieldName].remove((index-3)~/2 + numWeeks);
              } else if(courseData[fieldName].contains(-(index-3)~/2)){
                courseData[fieldName].remove(-(index-3)~/2);
                courseData[fieldName].add((index-3)~/2);
              } else {
                courseData[fieldName].add((index-3)~/2);
              }
              Provider.of<UserDB>(context, listen: false).updateCourses();
            },
            onLongPress: index == 3 ? null : (){
              if(!courseData[fieldName].contains(-(index-3)~/2)){
                courseData[fieldName].remove((index-3)~/2);
                courseData[fieldName].remove((index-3)~/2 + numWeeks);
                courseData[fieldName].add(-(index-3)~/2);
              } else {
                courseData[fieldName].remove(-(index-3)~/2);
              }
              Provider.of<UserDB>(context, listen: false).updateCourses();
            },
            child: Container(
              constraints: BoxConstraints.expand(),
              child: index == 3
                  ? Center(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 20),
                  ))
                  :
              iconToPut,
            )),
      );
    }

    Widget divv = Container(
        height: 5,
        child: Divider(color: Colors.black38,),
      );

    //List<Widget> widgetList = List.generate(numRows*2-1, (index) => index%2==0 ? press : divv);
    List<Widget> widgetList = [];
    if(courseOptions.isSingleton){
      widgetList.add(press(label: "Class", fieldName: Strings.singleton));
    } else {
      if(courseOptions.lectureCount>0){
        String plural = courseOptions.lectureCount>1 ? "s" : "";
        widgetList.add(press(label: Strings.firstLecture + plural, fieldName: Strings.firstLecture, count: courseOptions.lectureCount));
        widgetList.add(divv);
      }
      if(courseOptions.tutorialCount>0){
        String plural = courseOptions.tutorialCount>1 ? "s" : "";
        widgetList.add(press(label: Strings.tutorial + plural, fieldName: Strings.tutorial, count: courseOptions.tutorialCount));
        widgetList.add(divv);
      }
      if(courseOptions.workShopCount>0){
        String plural = courseOptions.workShopCount>1 ? "s" : "";
        widgetList.add(press(label: Strings.workshop + plural, fieldName: Strings.workshop, count: courseOptions.workShopCount));
        widgetList.add(divv);
      }
      widgetList.removeLast();
    }

    return Column(
        children: widgetList
    );
  }
}