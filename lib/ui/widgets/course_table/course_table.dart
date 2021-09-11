import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/models/course_options.dart';
import 'package:tasky/app/services/user_db.dart';

class CourseTableWidget extends StatefulWidget {
  @override
  _CourseTableWidgetState createState() => _CourseTableWidgetState();
}

class _CourseTableWidgetState extends State<CourseTableWidget> {
  //Returns a course table built from the given input
  Widget gridMaker(List courseOrder, Map courseProgressMap, Size screenSize, int numOfWeeks){

    //Converts course info to list of strings - Appear on left side of the table
    List courseListMaker(List courseOrder, Map courseProgressMap){
      List resultList = [];
      courseOrder.forEach(
              (element) {
            if(courseProgressMap[element].containsKey('Singleton')){
              resultList.add(element);
            }
            if(courseProgressMap[element].containsKey('Lecture')){
              resultList.add(element + ' - ' + 'Lecture');
            }
            if(courseProgressMap[element].containsKey('Tutorial')){
              resultList.add(element + ' - ' + 'Tutorial');
            }
          }
      );
      return resultList;
    }

    //Auxiliary function to prepare table data
    List auxListMaker(List courseOrder, Map courseProgressMap){
      List resultList = [];
      courseOrder.forEach(
              (element) {
            if(courseProgressMap[element].containsKey('Singleton')){
              resultList.add([element,'Singleton']);
            }
            if(courseProgressMap[element].containsKey('Lecture')){
              resultList.add([element,'Lecture']);
            }
            if(courseProgressMap[element].containsKey('Tutorial')){
              resultList.add([element,'Tutorial']);
            }
          }
      );
      return resultList;
    }

    //Auxiliary variables for building the table
    final List courseList = courseListMaker(courseOrder, courseProgressMap);
    final int numOfCourses = courseList.length;
    final int columnCount = numOfWeeks+2;
    final int rowCount = numOfCourses+1;

    //Table measurements
    final double tableWidth = min(1500,screenSize.width*0.8);
    final double tableHeight = min(tableWidth/(2*columnCount)*rowCount,screenSize.height-AppBar().preferredSize.height);

    //Returns appropriate table unit for the given index in the Gridview
    Widget tableUnitMaker(index){

      //Updates table unit with the given index to mark/unmark completed task
      toggleTableUnit(int index){
        assert(index>=columnCount);
        assert(index%columnCount>=2);
        int rowNum = -1 + index ~/ columnCount;
        int placement = index % columnCount;
        List auxList = (auxListMaker(courseOrder, courseProgressMap))[rowNum];
        List tempList = (courseProgressMap[auxList[0]])[auxList[1]];
        if(tempList.contains(placement)){
          tempList.remove(placement);
        } else {
          tempList.remove(placement+columnCount);
          tempList.add(placement);
        }
        (courseProgressMap[auxList[0]])[auxList[1]] = tempList;
        Provider.of<UserDB>(context,listen: false).updateProgressMap(courseProgressMap);
      }

      //Updates table unit with the given index to mark/unmark pending task
      togglePendingTableUnit(int index){
        assert(index>=columnCount);
        assert(index%columnCount>=2);
        int rowNum = -1 + index ~/ columnCount;
        int placement = index % columnCount;
        List auxList = (auxListMaker(courseOrder, courseProgressMap))[rowNum];
        List tempList = (courseProgressMap[auxList[0]])[auxList[1]];
        if(tempList.contains(placement+columnCount)){
          tempList.remove(placement+columnCount);
        } else {
          tempList.remove(placement);
          tempList.add(placement+columnCount);
        }
        (courseProgressMap[auxList[0]])[auxList[1]] = tempList;
        Provider.of<UserDB>(context,listen: false).updateProgressMap(courseProgressMap);
      }

      //Returns non-tappable table unit for the given index in the Gridview
      Widget rawTableUnitMaker(int index){

        //Returns appropriate icon for the item with the given index in the table
        Widget iconFromIndex(int index){
          int rowNum = -1 + index ~/ columnCount;
          int placement = index % columnCount;
          List auxListA = auxListMaker(courseOrder, courseProgressMap)[rowNum];
          List tempListA = (courseProgressMap[auxListA[0]])[auxListA[1]];
          if(tempListA.contains(placement)){
            return FittedBox(fit: BoxFit.fitHeight, child: Icon(Icons.check_rounded));
          }
          if(tempListA.contains(placement+columnCount)){
            return FittedBox(fit: BoxFit.scaleDown, child: Icon(Icons.circle,color: Colors.grey,));
          }
          return null;
        }

        //Auxillary function to check if current index is that of a pending entry
        //TODO: Rewrite
        bool isPending(int index){
          int rowNum = -1 + index ~/ columnCount;
          int placement = index % columnCount;
          List auxListA = auxListMaker(courseOrder, courseProgressMap)[rowNum];
          List tempListA = (courseProgressMap[auxListA[0]])[auxListA[1]];
          if(tempListA.contains(placement+columnCount)){
            return true;
          } else {
            return false;
          }
        }

        return Container(
          decoration: BoxDecoration(
              color: index<columnCount ? Colors.greenAccent : null,
              border: Border(
                  left: BorderSide(width: index%columnCount==0 ? 2 : 1),
                  right: BorderSide(width: index%columnCount==columnCount-1 ? 2 : 1),
                  top: BorderSide(width: index<columnCount ? 2 : 1),
                  bottom: BorderSide(width: index>=columnCount*(rowCount-1) ? 2 : 1)
              )
          ),
          child: FittedBox(
            fit: index<columnCount ? BoxFit.scaleDown : (isPending(index) ? BoxFit.scaleDown : BoxFit.fitHeight),
            child: Container(
              child: Center(child: index<columnCount ? FittedBox(fit: BoxFit.scaleDown, child: Text((index-1).toString(), style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold))) : iconFromIndex(index)),
            ),
          ),
        );
      }

      //Add tapping functionality if necessary
      if(index>=columnCount && index%columnCount>=2 && index%columnCount<columnCount){
        return InkWell(
          child: rawTableUnitMaker(index),
          onTap: () => toggleTableUnit(index),
          onLongPress: () => togglePendingTableUnit(index),
          onDoubleTap: () => togglePendingTableUnit(index),
        );
      } else {
        return rawTableUnitMaker(index);
      }
    }

    var content = courseOrder.length==0 ?
    Text("No courses found. Click on the Plus button to add some!",style: TextStyle(fontSize: 24),)
        :
    Stack(
      children: [
        Container(
          width: tableWidth,
          height: tableHeight,
          child: GridView.count(
            childAspectRatio: (tableWidth/tableHeight) * (rowCount/columnCount),
            crossAxisCount: columnCount,
            children: List.generate(columnCount * rowCount, tableUnitMaker),
          ),
        ),
        Container(
          width: 2*tableWidth/columnCount,
          height: tableHeight,
          child: GridView.count(
            childAspectRatio: (tableWidth/tableHeight) * (rowCount/columnCount) * 2,
            crossAxisCount: 1,
            children: List.generate(rowCount,
                    (index) => Container(
                  child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text(index==0 ? "Course" : courseList[index-1],style: TextStyle(fontWeight: FontWeight.bold),)),),
                  decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      border: Border(
                          left: BorderSide(width: 2),
                          right: BorderSide(width: 1),
                          top: BorderSide(width: index==0 ? 2 : 1),
                          bottom: BorderSide(width: index==rowCount-1 ? 2 : 1)
                      )
                  ),
                )
            ),
          ),
        )
      ],
    );

    return content;
  }

  @override
  Widget build(BuildContext context) {
    List courseOrder = Provider.of<UserDB>(context).courseOrder;
    Map courseProgressMap = Provider.of<UserDB>(context).courseProgressMap;

    List<String> dialogOptions = [
      //"2 Lectures + 1 Tutorial",
      "Lecture + Tutorial",
      "Lecture only",
      "No Label"
    ];

    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Course Table")),),
      drawer: NavigationDrawer(),
      body: Center(
        child: gridMaker(courseOrder, courseProgressMap,MediaQuery.of(context).size,13),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
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
}