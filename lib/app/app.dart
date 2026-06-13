import 'dart:html' as html;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tasky/app/services/firebase_auth_service.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/authentication/sign_in/sign_in_widget.dart';
import 'package:provider/provider.dart';
import 'package:tasky/ui/widgets/home/home_widget.dart';
import 'package:tasky/ui/widgets/homework_table/task_table.dart';
import 'package:tasky/ui/widgets/new_course_table/new_course_table.dart';

import 'models/user_data.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  bool _announcementShown = false;

  /**
   * Shows the remote-controlled announcement banner (if enabled and not
   * previously dismissed for this message). Uses the app-level
   * ScaffoldMessenger so the banner survives page navigation.
   */
  void _maybeShowAnnouncement(BuildContext context) {
    UserDB userDB = Provider.of<UserDB>(context, listen: false);
    if (_announcementShown ||
        !userDB.announcementEnabled ||
        userDB.announcementMessage == null ||
        userDB.announcementMessage == "") {
      return;
    }
    if (html.window.localStorage['dismissedAnnouncement'] ==
        userDB.announcementMessage) {
      return;
    }
    _announcementShown = true;
    String message = userDB.announcementMessage;
    String url = userDB.announcementUrl;
    Color mainColor = userDB.mainColor;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      messenger.showMaterialBanner(MaterialBanner(
        leading: Icon(Icons.campaign, color: mainColor),
        backgroundColor: Colors.white,
        content: Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          if (url != null && url != "")
            TextButton(
              child: Text("CHECK IT OUT",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                html.window.open(url, '_blank');
              },
            ),
          TextButton(
            child: Text("DISMISS"),
            onPressed: () {
              html.window.localStorage['dismissedAnnouncement'] = message;
              messenger.hideCurrentMaterialBanner();
            },
          ),
        ],
      ));
    });
  }

  Widget firstPage(int pageNum){
    switch(pageNum){
      case 0:{
        return HomeWidget();
      }
      break;
      case 1:{
        return NewCourseTableWidget();
      }
      break;
      case 2:{
        return TaskWidget();
      }
      break;
      //Out-of-range defaultPage (corrupted doc) must not return null
      default:{
        return HomeWidget();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context,snapshot){
        if(snapshot.hasError){
          return MaterialApp(home: Scaffold(body: Center(child: Text(snapshot.error.toString()))));
        } else if(snapshot.connectionState == ConnectionState.done){
          return MaterialApp(
            title: 'Tasky',
            theme: ThemeData(
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: Consumer<UserData>(
              builder: (_, user, __) {
                if (user == null) {
                  return const SignInWidget();
                } else {
                  return Provider.of<FirebaseAuthService>(context).isInitialized ? firstPage(Provider.of<UserDB>(context).defaultPage) : FutureBuilder(
                      future: Provider.of<UserDB>(context).downloadCourseData(),
                      builder: (context,snapshot){
                        if(snapshot.hasError){
                          return Center(child: Text(snapshot.error.toString()));
                        } else if(snapshot.connectionState == ConnectionState.done){
                          Provider.of<FirebaseAuthService>(context).markInitialized();
                          _maybeShowAnnouncement(context);
                          return firstPage(Provider.of<UserDB>(context).defaultPage);
                        }
                        return Center(child: CircularProgressIndicator());
                      });
                }
              },
            ),
          );
        }
        return MaterialApp(home: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
