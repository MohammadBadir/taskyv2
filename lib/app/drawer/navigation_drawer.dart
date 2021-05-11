import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/models/user_data.dart';
import 'package:tasky/app/services/firebase_auth_service.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/authentication/sign_in/sign_in_widget.dart';
import 'package:tasky/ui/widgets/course_table/course_table.dart';
import 'package:tasky/ui/widgets/grade_calc/grade_calc.dart';
import 'package:tasky/ui/widgets/home/home_widget.dart';

class NavigationDrawer extends StatelessWidget {
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  Provider.of<FirebaseAuthService>(context).currentUser().displayName,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
          ],
        ),
      ),
    ), Divider(),
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
      ListTile(title: Text("  Course Table"),onTap: (){
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return CourseTableWidget();
            },
          ),
        );
      },),
      ListTile(title: Text("  Homework"),onTap: (){
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return HomeworkWidget();
            },
          ),
        );
      },)

    ],
    ),
    );
  }
}