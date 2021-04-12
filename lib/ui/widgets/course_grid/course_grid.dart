import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/my_drawer.dart';
import 'package:tasky/app/models/course_options.dart';
import 'package:tasky/app/services/user_db.dart';

class CourseGridWidget extends StatelessWidget {
  Widget gridMaker(List courseOrder, Map courseProgressMap){
    return Container();
  }

  final Column Function(BuildContext context) oldContent = (context) => Column(
    children: [
      Text(Provider.of<UserDB>(context).courseOrder.toString()),
      ElevatedButton(
          onPressed: () {
            Provider.of<UserDB>(context,listen: false).addWord("AddedWord");
          },
          child: Text("AddWord")
      ),
      ElevatedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context){
                  String courseName = "Georgia";
                  return AlertDialog(
                    title: Text("Enter Course Name"),
                    content: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Course Name",
                      ),
                      onChanged: (String str){
                        courseName = str;
                      },
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
                            Provider.of<UserDB>(context,listen: false).addCourse(courseName, CourseOptions(true, false));
                            Navigator.of(context).pop();
                          },
                          child: Text("Confirm")
                      ),
                    ],
                  );
                }
            );
          },
          child: Text("Add Course")
      ),
    ],
  );

  List listMaker(List courseOrder, Map courseProgressMap){
    List resultList = [];
    courseOrder.forEach(
            (element) {
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

  List auxListMaker(List courseOrder, Map courseProgressMap){
    List resultList = [];
    courseOrder.forEach(
            (element) {
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

  @override
  Widget build(BuildContext context) {
    List courseOrder = Provider.of<UserDB>(context).courseOrder;
    Map courseProgressMap = Provider.of<UserDB>(context).courseProgressMap;
    List moddedList = listMaker(courseOrder, courseProgressMap);
    double gridWidth = min(1500,MediaQuery.of(context).size.width*0.8);

    int numOfWeeks = 13;
    int numOfCourses = moddedList.length;

    int columnCount = numOfWeeks+2;
    int rowCount = numOfCourses+1;
    double gridHeight = min(gridWidth/(2*columnCount)*rowCount,MediaQuery.of(context).size.height-AppBar().preferredSize.height);

    Widget Function(int index) gridPlaceIcon = (index){
      int rowNum = -1 + index ~/ columnCount;
      int placement = index % columnCount;
      List auxListA = auxListMaker(courseOrder, courseProgressMap)[rowNum];
      List tempListA = (courseProgressMap[auxListA[0]])[auxListA[1]];
      if(tempListA.contains(placement)){
        return Icon(Icons.check);
      }
      if(tempListA.contains(placement+columnCount)){
        return Icon(Icons.circle,color: Colors.grey,);
      }
      return null;
    };

    Container Function(int index) gridUnit = (index) => Container(
      child: Center(child: index<columnCount ? Text((index-1).toString(), style: TextStyle(fontSize: 22)) : gridPlaceIcon(index)),
      decoration: BoxDecoration(
          color: index<columnCount ? Colors.greenAccent : null,
          border: Border(
              left: BorderSide(width: index%columnCount==0 ? 2 : 1),
              right: BorderSide(width: index%columnCount==columnCount-1 ? 2 : 1),
              top: BorderSide(width: index<columnCount ? 2 : 1),
              bottom: BorderSide(width: index>=columnCount*(rowCount-1) ? 2 : 1)
          )
      ),
    );

    Null Function(int index) tableModifier = (index){
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
    };

    Null Function(int index) tableDotModifier = (index){
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
    };

    if(courseOrder.length==0){
      return Scaffold(
        appBar: AppBar(title: Center(child: Text("Course Grid")),),
        drawer: MyDrawer(),
        body: Center(child: Text("No courses found. Click on the Plus button to add some!",style: TextStyle(fontSize: 24),)),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context){
                  String courseName;
                  return AlertDialog(
                    title: Text("Enter Course Name"),
                    content: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Course Name",
                      ),
                      onChanged: (String str){
                        courseName = str;
                      },
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
                            if(courseName==null){
                              return;
                            }
                            Provider.of<UserDB>(context,listen: false).addCourse(courseName, CourseOptions(true, true));
                            Navigator.of(context).pop();
                          },
                          child: Text("Confirm")
                      ),
                    ],
                  );
                }
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Course Grid")),),
      drawer: MyDrawer(),
      body: Center(
        child: Stack(
          children: [
            Container(
              width: gridWidth,
              height: gridHeight,
              child: GridView.count(
                childAspectRatio: (gridWidth/gridHeight) * (rowCount/columnCount),
                crossAxisCount: columnCount,
                children: List.generate(columnCount * rowCount,
                        (index) => index>=columnCount && index%columnCount>=2 && index%columnCount<columnCount ? InkWell(child: gridUnit(index), onTap: (){tableModifier(index); }, onLongPress: (){tableDotModifier(index);},) : gridUnit(index)
                ),
              ),
            ),
            Container(
              width: 2*gridWidth/columnCount,
              height: gridHeight,
              child: GridView.count(
                childAspectRatio: (gridWidth/gridHeight) * (rowCount/columnCount) * 2,
                crossAxisCount: 1,
                children: List.generate(rowCount,
                        (index) => Container(
                      child: Center(child: Text(index==0 ? "Course" : moddedList[index-1],style: TextStyle(fontWeight: FontWeight.bold),),),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          showDialog(
              context: context,
              builder: (BuildContext context){
                String courseName;
                return AlertDialog(
                  title: Text("Enter Course Name"),
                  content: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Course Name",
                    ),
                    onChanged: (String str){
                      courseName = str;
                    },
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
                          if(courseName==null){
                            return;
                          }
                          Provider.of<UserDB>(context,listen: false).addCourse(courseName, CourseOptions(true, true));
                          Navigator.of(context).pop();
                        },
                        child: Text("Confirm")
                    ),
                  ],
                );
              }
          );
        },
      ),
    );
  }
}