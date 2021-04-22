import 'dart:html';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tasky/app/services/firebase_auth_service.dart';
import 'package:tasky/app/services/user_db.dart';
import 'package:tasky/ui/widgets/authentication/sign_in/sign_in_widget.dart';
import 'package:provider/provider.dart';
import 'package:tasky/ui/widgets/home/home_widget.dart';

import 'models/user_data.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
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
            ),
          );
        }
        return MaterialApp(home: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
