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
import 'package:tasky/ui/widgets/new_course_table/widgets/week_bar.dart';

import 'no_courses.dart';

class NewCourseTableWidget extends StatefulWidget {
  @override
  _NewCourseTableWidgetState createState() => _NewCourseTableWidgetState();
}

class _NewCourseTableWidgetState extends State<NewCourseTableWidget> {
  Widget cardMaker(Widget content, double cardHeight,
      {bool includeBorders = false, Color mainColor = Colors.blueAccent, Color secondaryColor = Colors.blue}) {
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
                        bottom: BorderSide(color: mainColor, width: 5),
                        top: BorderSide(color: mainColor, width: 5)))
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
    UserDB userDB = Provider.of<UserDB>(context);

    List courseOrder = userDB.courseOrder;
    Map courseProgressMap = userDB.courseProgressMap;
    Color mainColor = userDB.mainColor;
    Color secondaryColor = userDB.secondaryColor;

    //courseProgressMap.forEach((key, value) { print(MapEntry(key, value)); });

    List<Widget> courseCardList = [];
    courseOrder.forEach((courseName) {
      courseCardList.add(createCourseCard(courseName, courseProgressMap[courseName],mainColor: mainColor));
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
        ],
      )) : ScreenTooSmallWidget(),
      floatingActionButton: MediaQuery.of(context).size.width<950 ? null : FloatingActionButton(
        child: /*Provider.of<UserDB>(context).editMode ? Icon(Icons.check_rounded, size: 35.0,) :*/ Icon(Icons.edit),
        backgroundColor: mainColor,
        onPressed: (){
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
                                                            CourseOptions courseOptions = courseOptionsFromInfo(courseProgressMap[oldCourseName]["info"]);
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

  Widget createCourseCard(String courseName, Map courseMap, {Color mainColor = Colors.blueAccent}) {
    int numOfRows = courseMap['data'].length;
    //List<String> names = ["Lecture #1"];
    VerticalDivider indexNeedsDivider(int index) =>
        index == 0 || index == 2 || index == 30 ? null : VerticalDivider(color: Colors.black38);
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
        50.0*numOfRows,
        includeBorders: true,
        mainColor: mainColor);
  }

  CourseOptions courseOptionsFromInfo(Map courseInfo){
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
    CourseOptions courseOptions = courseOptionsFromInfo(courseMap['info']);
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 20),
                    ),
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
        widgetList.add(press(label: Strings.lecture + plural, fieldName: Strings.lecture, count: courseOptions.lectureCount));
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