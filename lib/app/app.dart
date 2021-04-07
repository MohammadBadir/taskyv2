import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tasky/ui/widgets/authentication/sign_in/sign_in_widget.dart';
import 'package:tasky/ui/widgets/home/home_widget.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';

class MyApp extends StatelessWidget {
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
            title: 'Material App',
            theme: ThemeData(
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: Consumer<UserData>(
              builder: (_, user, __) {
                if (user == null) {
                  return const SignInWidget();
                } else {
                  return const HomeWidget();
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
