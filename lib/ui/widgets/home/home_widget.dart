import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/navigation_drawer.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/app_bar/tasky_app_bar.dart';

import '../../../app/constants/strings.dart';
import '../../../app/services/firebase_auth_service.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: taskyAppBar(context, "Home"),
      drawer: NavigationDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Welcome back, "+Provider.of<UserDB>(context).displayName,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold),),
            Text("You have no pending tasks" + Provider.of<UserDB>(context).currentSemester.toString(),
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }
}
