import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/ui/widgets/course_page/course_page.dart';
import '../../../../app/constants/strings.dart';
import '../../../../app/models/course_options.dart';
import '../../../../app/services/user_db.dart';
import 'card_wrapper.dart';

class CourseCard extends StatelessWidget {
  final String courseName;
  final Map courseMap;
  final Color mainColor;

  const CourseCard(this.courseName, this.courseMap, {this.mainColor = Colors.blueAccent, Key key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    Column courseColumn(int index, Map courseMap, String courseName) {
      int numWeeks = 13;
      CourseOptions courseOptions = courseOptionsFromInfo(courseMap['info']);
      Map courseData = courseMap['data'];
      int numRows = courseData.length;

      Widget press({String label, String fieldName, int count = 1}) {
        //TODO: Make this into an organized class. At the moment it's very hard to read.
        Widget iconToPut;
        if(courseData[fieldName].contains((index-3)~/2)){
          iconToPut = FittedBox(fit: BoxFit.fitHeight, child: Icon(Icons.check_rounded));
        } else if(count==2 && courseData[fieldName].contains((index-3)~/2 + numWeeks)){
          iconToPut = FittedBox(fit: BoxFit.fitHeight, child: Icon(Icons.done_all_rounded));
        } else if(courseData[fieldName].contains(-(index-3)~/2)){
          iconToPut = FittedBox(fit: BoxFit.scaleDown, child: Icon(Icons.circle, color: Colors.grey,));
        }

        return Expanded(
          child: InkWell(
              onTap: index == 3 ? null : () {
                Provider.of<UserDB>(context, listen: false).standardUpdateCourseProgress(courseData, fieldName, numWeeks, count, index);
              },
              onLongPress: index == 3 ? null : (){
                Provider.of<UserDB>(context, listen: false).pendingUpdateCourseProgress(courseData, fieldName, numWeeks, index);
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

    int numOfRows = courseMap['data'].length;

    VerticalDivider indexNeedsDivider(int index) =>
        index == 0 || index == 2 || index == 30 ? null : VerticalDivider(color: Colors.black38);

    int flexByIndex(int index) => index == 1 ? 6 : (index == 3 ? 3 : 2);
    return CardWrapper(
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
                          ? InkWell(
                        onTap: (){
                          //temporary
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return CoursePage();
                              },
                            ),
                          );
                        },
                            child: Text(
                        courseName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                      ),
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
}
