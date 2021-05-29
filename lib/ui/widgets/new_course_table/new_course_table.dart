import 'package:flutter/material.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';

class NewCourseTableWidget extends StatefulWidget{
  @override
  _NewCourseTableWidgetState createState() => _NewCourseTableWidgetState();
}

class _NewCourseTableWidgetState extends State<NewCourseTableWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("New Course Table")),),
      drawer: NavigationDrawer(),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: Card(
              color: Colors.white,
              child: ClipPath(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("  Compilation", style: TextStyle(fontSize: 25,),)
                    ],
                  ),
                  // height: 100,
                  decoration: BoxDecoration(
                      border: Border(bottom:BorderSide(color: Colors.blueAccent, width: 5) ,top: BorderSide(color: Colors.blueAccent, width: 5))
                  ),
                )
                ,
                clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3))),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            child: Card(
              color: Colors.white,
              child: ClipPath(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("  Software Design", style: TextStyle(fontSize: 25,),)
                    ],
                  ),
                  // height: 100,
                  decoration: BoxDecoration(
                      border: Border(bottom:BorderSide(color: Colors.blueAccent, width: 5) ,top: BorderSide(color: Colors.blueAccent, width: 5))
                  ),
                )
                ,
                clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3))),
              ),
            ),
          )
        ],
      ),
    );
  }
}