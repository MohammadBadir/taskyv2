import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/my_drawer.dart';

import '../../../app/constants/strings.dart';
import '../../../app/services/firebase_auth_service.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Home")),),
      drawer: MyDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              maxRadius: 50,
              backgroundImage: NetworkImage(Provider.of<FirebaseAuthService>(context).currentUser().photoURL),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                Provider.of<FirebaseAuthService>(context).currentUser().displayName,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            RaisedButton(
              onPressed: () {
                context.read<FirebaseAuthService>().signOut();
              },
              child: Text(Strings.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
