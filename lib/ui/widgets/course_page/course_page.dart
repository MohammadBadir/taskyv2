import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/ui/widgets/new_course_table/widgets/week_bar.dart';

import '../../../app/services/user_db.dart';
import '../app_bar/tasky_app_bar.dart';
import '../new_course_table/widgets/course_card.dart';

class CoursePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserDB userDB = Provider.of<UserDB>(context);

    Map courseProgressMap = userDB.courseProgressMap;
    Color mainColor = userDB.mainColor;

    String courseName = "banana";

    var courseCard = CourseCard(courseName, courseProgressMap[courseName], mainColor: mainColor);

    return Scaffold(
      appBar: AppBar(title: Center(child: Text(courseName))),
      drawer: NavigationDrawer(),
      body: Column(
        children: [
          WeekBar(),
          courseCard
        ],
      ),
    );
  }
}
