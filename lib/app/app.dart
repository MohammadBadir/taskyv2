import 'package:flutter/material.dart';
import 'package:tasky/ui/widgets/authentication/sign_in/sign_in_widget.dart';
import 'package:tasky/ui/widgets/home/home_widget.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
