import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';

class NewCourseTableWidget extends StatefulWidget{
  @override
  _NewCourseTableWidgetState createState() => _NewCourseTableWidgetState();
}

class _NewCourseTableWidgetState extends State<NewCourseTableWidget> {
  Widget cardMaker(Widget content, double cardHeight){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: cardHeight,
      child: Card(
        color: Colors.white,
        child: ClipPath(
          child: Container(
            child: content,
          ),
          clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3))
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget weekRow;
    Widget listThing = Container(
      color: Colors.blueAccent,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(16, (index) => Container(
          margin: EdgeInsets.fromLTRB(2.5, 5, 2.5, 5),
          child: Center(child: Text((index+1).toString(),style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),)),
          width: (MediaQuery.of(context).size.width-10)/16-5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white
          ),
        )
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Center(child: Text("New Course Table")),),
      drawer: NavigationDrawer(),
      body: Column(
        children: [
          cardMaker(listThing, 50),
          cardMaker(Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("  Jimmy", style: TextStyle(fontSize: 25,),)
            ],
          ), 100),
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