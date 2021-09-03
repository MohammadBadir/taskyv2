import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/constants/strings.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/services/user_db.dart';

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
    
    Map moddedProgressMap = courseProgressMap.map((key, value){
      Map moddedSubMap = value.map((subKey,subVal){
        List moddedList = subVal.map((val) {
          int num = cast<int>(val);
          return num<=14 ? num-1 : num-3;
        }).toList();
        return MapEntry(subKey, moddedList);
      });

      return MapEntry(key, moddedSubMap);
    });

    moddedProgressMap.forEach((key, value) {print(MapEntry(key, value));});

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

    List<Widget> listContent = MediaQuery.of(context).size.width>=950 ? [
      cardMaker(weekRow, 50, includeBorders: true),
      courseCard("Introduction to Computer Science", moddedProgressMap["Apple"]),
      courseCard("Ninja", moddedProgressMap["Ninja"]),
      courseCard("Apple", moddedProgressMap["Apple"]),
      courseCard("Coconut", moddedProgressMap["Apple"]),
      cardMaker(
          Row(
            children: List.generate(
                29,
                    (index) => index % 2 == 0
                    ? Container(
                  width: 5,
                  color: index == 0 || index == 28
                      ? Colors.blueAccent
                      : Colors.white,
                  child: index == 0 || index == 28
                      ? null
                      : VerticalDivider(),
                )
                    : Expanded(
                  child: Container(
                    child: Center(
                        child: index <= 2
                            ? Text(
                          index == 1
                              ? "Introduction to Biomechanical Engineering"
                              : (index ~/ 2).toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        )
                            : Column(
                          children: [
                            Expanded(
                                child: InkWell(
                                    onTap: () {},
                                    child: Container())),
                            Container(
                              height: 5,
                              child: Divider(),
                            ),
                            Expanded(
                                child: InkWell(
                                    onTap: () {},
                                    child: Container())),
                            Container(
                              height: 5,
                              child: Divider(),
                            ),
                            Expanded(
                                child: InkWell(
                                    onTap: () {},
                                    child: Container()))
                          ],
                        )),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  flex: index == 1 ? 3 : 1,
                )),
          ),
          150,
          includeBorders: true),
      Text(MediaQuery.of(context).size.width.toString())
    ] : [Center(
      child: Text("Expand Window Plz",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
    )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(Strings.newCourseTableTitle)),
      ),
      drawer: NavigationDrawer(),
      body: ListView(
        children: listContent,
      ),
    );
  }

  Widget courseCard(String courseName, Map courseData) {
    int numRows = courseData.length;
    List<String> names = ["Lecture #1"];
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
                                : clickThing(index, courseData)),
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

  Column clickThing(int indexx, Map courseData) {
    Widget press = Expanded(
        child: InkWell(
            onTap: indexx == 3 ? null : () {},
            child: Container(
              constraints: BoxConstraints.expand(),
              child: indexx == 3
                  ? Center(
                  child: Text(
                    Strings.firstLecture,
                    style: TextStyle(fontSize: 20),
                  ))
                  :
              courseData[Strings.firstLecture].contains((indexx-3)~/2) ?
              FittedBox(fit: BoxFit.fitHeight, child: Icon(Icons.check_rounded)) :
              (courseData[Strings.firstLecture].contains((indexx-3)~/2 + 13) ?
              FittedBox(fit: BoxFit.scaleDown, child: Icon(Icons.circle,color: Colors.grey,)) :
              null),
            )),
      );
    Widget divv = Container(
        height: 5,
        child: Divider(color: Colors.black38,),
      );
    List<Widget> widgetList = List.generate(3, (index) => index%2==0 ? press : divv);
    return Column(
        children: true ? widgetList : [
          Expanded(
              child: InkWell(
                  onTap: indexx == 3 ? null : () {},
                  child: Container(
                    constraints: BoxConstraints.expand(),
                    child: indexx == 3
                        ? Center(
                        child: Text(
                          Strings.firstLecture,
                          style: TextStyle(fontSize: 20),
                        ))
                        :
                    courseData[Strings.firstLecture].contains((indexx-3)~/2) ?
                    FittedBox(fit: BoxFit.fitHeight, child: Icon(Icons.check_rounded)) :
                    (courseData[Strings.firstLecture].contains((indexx-3)~/2 + 13) ?
                    FittedBox(fit: BoxFit.scaleDown, child: Icon(Icons.circle,color: Colors.grey,)) :
                    null),
                  ))),
          Container(
            height: 5,
            child: Divider(color: Colors.black38,),
          ),
          Expanded(
              child: InkWell(
                  onTap: indexx == 3 ? null : () {},
                  child: Container(
                    constraints: BoxConstraints.expand(),
                    child: indexx == 3
                        ? Center(
                        child: Text(
                          Strings.tutorial,
                          style: TextStyle(fontSize: 20),
                        ))
                        :
                    courseData[Strings.tutorial].contains((indexx-3)~/2) ?
                    FittedBox(fit: BoxFit.fitHeight, child: Icon(Icons.check_rounded)) :
                    (courseData[Strings.tutorial].contains((indexx-3)~/2 + 13) ?
                    FittedBox(fit: BoxFit.scaleDown, child: Icon(Icons.circle,color: Colors.grey,)) :
                    null),
                  )))        ],
      );
  }
}
