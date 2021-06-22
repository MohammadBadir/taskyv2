import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';

class NewCourseTableWidget extends StatefulWidget{
  @override
  _NewCourseTableWidgetState createState() => _NewCourseTableWidgetState();
}

class _NewCourseTableWidgetState extends State<NewCourseTableWidget> {
  Widget cardMaker(Widget content, double cardHeight, {bool includeBorders = false}){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: cardHeight,
      child: Card(
        color: Colors.white,
        child: ClipPath(
          child: Container(
            child: content,
            decoration: includeBorders ? BoxDecoration(
                border: Border(bottom:BorderSide(color: Colors.blueAccent, width: 5) ,top: BorderSide(color: Colors.blueAccent, width: 5))
            ) : null,
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
    Widget weekRow = Container(
      color: Colors.green,
      child: Row(
        children: List.generate(
            31,
            (index) => index % 2 == 0
                ? Container(
                    width: 5,
                    color: Colors.blueAccent,
                  )
                : Expanded(
                    child: Container(
                      child: Center(
                          child: Text(
                        index == 1 ? "Course" : (index ~/ 2).toString(),
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      )),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white),
                    ),
                    flex: index == 1 ? 3 : 1,
                  )),
      ),
    );
    // Widget listThing = Container(
    //   color: Colors.blueAccent,
    //   child: ListView(
    //     scrollDirection: Axis.horizontal,
    //     children: List.generate(16, (index) => Container(
    //       margin: EdgeInsets.fromLTRB(2.5, 5, 2.5, 5),
    //       child: Center(child: Text((index+1).toString(),style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),)),
    //       width: (MediaQuery.of(context).size.width-10)/16-5,
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(3),
    //         color: Colors.white
    //       ),
    //     )
    //     ),
    //   ),
    // );

    return Scaffold(
      appBar: AppBar(title: Center(child: Text("New Course Table")),),
      drawer: NavigationDrawer(),
      body: Column(
        children: [
          cardMaker(weekRow, 50, includeBorders: true),
          // cardMaker(Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Text("  Jimmy", style: TextStyle(fontSize: 25,),)
          //   ],
          // ), 100),
          cardMaker(
              Row(
                children: List.generate(
                    31,
                    (index) => index % 2 == 0
                        ? Container(
                            width: 5,
                            color: index==0 || index==30 ? Colors.white : Colors.white,
                            child: index==0 || index==30 || index == 2 ? null : VerticalDivider(),
                          )
                        : Expanded(
                            child: Container(
                              child: Center(
                                  child: index <= 2 ? Text(
                                    index == 1 ? "Introduction to Computer Science" : (index ~/ 2).toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 24, fontWeight: FontWeight.bold),
                                  ) :Column(children: [Expanded(child: InkWell(onTap: index==3 ? null : (){},child: Container(child: index == 3 ? Center(child: Text("Lecture", style: TextStyle(fontSize: 20),)) : null,))),Container(height: 5, child: Divider(),),Expanded(child: InkWell(onTap: index==3 ? null : (){},child: Container(child: index == 3 ? Center(child: Text("Tutorial", style: TextStyle(fontSize: 20),)) : null,)))],)),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),),
                            ),
                            flex: index == 1 ? 3 : 1,
                          )),
              ),
              100, includeBorders: true),
          cardMaker(
              Row(
                children: List.generate(
                    29,
                        (index) => index % 2 == 0
                        ? Container(
                      width: 5,
                      color: index==0 || index==28 ? Colors.blueAccent : Colors.white,
                      child: index==0 || index==28 ? null : VerticalDivider(),
                    )
                        : Expanded(
                      child: Container(
                        child: Center(
                            child: index <= 2 ? Text(
                              index == 1 ? "Introduction to Computer Science" : (index ~/ 2).toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ) :Column(children: [Expanded(child: InkWell(onTap:(){},child: Container())),Container(height: 5, child: Divider(),),Expanded(child: InkWell(onTap:(){},child: Container())),Container(height: 5, child: Divider(),),Expanded(child: InkWell(onTap:(){},child: Container()))],)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),),
                      ),
                      flex: index == 1 ? 3 : 1,
                    )),
              ),
              150, includeBorders: true),
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