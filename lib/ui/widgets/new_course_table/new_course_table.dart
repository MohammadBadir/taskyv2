import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/constants/strings.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/models/course_options.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/new_course_table/screen_too_small.dart';

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

    courseProgressMap.forEach((key, value) {print(MapEntry(key, value));});

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
      //"2 Lectures + 1 Tutorial",
      "Lecture + Tutorial",
      "Lecture only",
      "No Label"
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: (){
          showDialog(
              context: context,
              builder: (BuildContext context){
                String courseName;
                int _selected;
                return StatefulBuilder(
                  builder: (context, setState){
                    return AlertDialog(
                      title: Text(" Enter Course Details"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("    Course Format:",style: TextStyle(color: Colors.grey),),
                          SizedBox(height: 10,),
                          Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width/3,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: 3,
                                itemBuilder: (BuildContext context, int index) {
                                  return RadioListTile(
                                      title: Text(dialogOptions[index]),
                                      value: index,
                                      groupValue: _selected,
                                      onChanged: (value) {
                                        setState(() {
                                          _selected = index;
                                        });
                                      });
                                }),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Course Name",
                            ),
                            onChanged: (String str){
                              courseName = str;
                            },
                          ),
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
                              if(courseName==null||_selected==null){
                                return;
                              }
                              CourseOptions courseOptions;
                              if(_selected==2){
                                courseOptions = CourseOptions.singleton();
                              } else {
                                courseOptions = CourseOptions.general();
                                courseOptions.lectureCount = _selected==0||_selected==1 ? 1 : 0;
                                courseOptions.tutorialCount = _selected==0 ? 1 : 0;
                              }
                              Provider.of<UserDB>(context,listen: false).addCourse(courseName, courseOptions);
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
                                : clickThing(index, courseMap)),
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
    CourseOptions options = CourseOptions.general();
    options.lectureCount = courseInfo['lectureCount'];
    options.tutorialCount = courseInfo['tutorialCount'];
    options.workShopCount = courseInfo['workshopCount'];
    if(options.lectureCount + options.tutorialCount + options.workShopCount == 0) {
      options.isSingleton = true;
    }
    return options;
  }

  Column clickThing(int indexx, Map courseMap) {
    CourseOptions courseOptions = courseOptionsFromData(courseMap['info']);
    Map courseData = courseMap['data'];
    int numRows = courseData.length;
    Widget press({String label, String fieldName, int count = 1}) => Expanded(
        child: InkWell(
            onTap: indexx == 3 ? null : () {},
            child: Container(
              constraints: BoxConstraints.expand(),
              child: indexx == 3
                  ? Center(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 20),
                  ))
                  :
              courseData[fieldName].contains((indexx-3)~/2) ?
              FittedBox(fit: BoxFit.fitHeight, child: Icon(Icons.check_rounded)) :
              (courseData[fieldName].contains((indexx-3)~/2 + 13) ?
              FittedBox(fit: BoxFit.scaleDown, child: Icon(Icons.circle,color: Colors.grey,)) :
              null),
            )),
      );

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
        widgetList.add(press(label: Strings.firstLecture, fieldName: Strings.firstLecture, count: courseOptions.lectureCount));
        widgetList.add(divv);
      }
      if(courseOptions.tutorialCount>0){
        widgetList.add(press(label: Strings.tutorial, fieldName: Strings.tutorial, count: courseOptions.tutorialCount));
        widgetList.add(divv);
      }
      if(courseOptions.workShopCount>0){
        widgetList.add(press(label: Strings.workshop, fieldName: Strings.workshop, count: courseOptions.workShopCount));
        widgetList.add(divv);
      }
      widgetList.removeLast();
    }

    return Column(
        children: widgetList
    );
  }
}