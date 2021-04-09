import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/services/firebase_auth_service.dart';
import 'package:tasky/ui/widgets/course_grid/course_grid.dart';
import 'package:tasky/ui/widgets/home/home_widget.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(child: ListView(children: [Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 51.0,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage: NetworkImage(Provider.of<FirebaseAuthService>(context).currentUser().photoURL),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Text(
                Provider.of<FirebaseAuthService>(context).currentUser().displayName,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
    ), Divider(),
      ListTile(title: Text("Home"),onTap: (){
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return HomeWidget();
            },
          ),
        );
      },),
      ListTile(title: Text("Course Grid"),onTap: (){
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return CourseGridWidget();
            },
          ),
        );
      },)
    ],
    ),
    );
  }
}