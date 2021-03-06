import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/constants/strings.dart';
import 'package:tasky/app/models/user_data.dart';
import 'package:tasky/app/services/firebase_auth_service.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/app_bar/tasky_app_bar.dart';
import 'package:tasky/ui/widgets/authentication/sign_in/sign_in_widget.dart';
import 'package:tasky/ui/widgets/homework_table/task_table.dart';
import 'package:tasky/ui/widgets/home/home_widget.dart';
import 'package:tasky/ui/widgets/new_course_table/new_course_table.dart';

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(child: ListView(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              Strings.version,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ],
      ),
      Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50.0,
              backgroundColor: Provider.of<UserDB>(context).mainColor,
              child: Center(child: Text(Provider.of<UserDB>(context).displayName[0], style: TextStyle(fontSize: 50, color: Colors.white))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  //Provider.of<FirebaseAuthService>(context).currentUser().displayName,
                    Provider.of<UserDB>(context).displayName,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
      TextButton(
        onPressed: () {
          context.read<FirebaseAuthService>().signOut();
        },
        child: Text(Strings.signOut),
      ),
      Divider(),
      ListTile(title: Text("  Home"),onTap: (){
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return Consumer<UserData>(
                builder: (_, user, __) {
                  if (user == null) {
                    return const SignInWidget();
                  } else {
                    return Provider.of<FirebaseAuthService>(context).isInitialized ? HomeWidget() : FutureBuilder(
                        future: Provider.of<UserDB>(context).downloadCourseData(),
                        builder: (context,snapshot){
                          if(snapshot.hasError){
                            return Center(child: Text(snapshot.error.toString()));
                          } else if(snapshot.connectionState == ConnectionState.done){
                            Provider.of<FirebaseAuthService>(context).markInitialized();
                            return HomeWidget();
                          }
                          return Center(child: CircularProgressIndicator());
                        });
                  }
                },
              );
            },
          ),
        );
      },),
      // ListTile(title: Text("  Course Table"),onTap: (){
      //   Navigator.of(context).pop();
      //   Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(
      //       builder: (BuildContext context) {
      //         return CourseTableWidget();
      //       },
      //     ),
      //   );
      // },),
      ListTile(title: Text("  Course Table"),onTap: (){
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return NewCourseTableWidget();
            },
          ),
        );
      },),
      ListTile(title: Text("  Assignments"),onTap: (){
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return TaskWidget();
            },
          ),
        );
      },),
      ListTile(title: Text("  Settings"),onTap: (){
        Navigator.of(context).pop();
        showSettingsDialog(context);
      },)
    ],
    ),
    );
  }
}