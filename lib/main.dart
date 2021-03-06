import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/services/firebase_auth_service.dart';
import 'app/services/user_db.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    /// Inject the [FirebaseAuthService]
    /// and provide a stream of [User]
    ///
    /// This needs to be above [MaterialApp]
    /// At the top of the widget tree, to
    /// accomodate for navigations in the app
    MultiProvider(
      providers: [
        Provider(
          create: (_) => FirebaseAuthService(),
        ),
        StreamProvider(
          create: (context) =>
          context
              .read<FirebaseAuthService>()
              .onAuthStateChanged,
        ),
        ChangeNotifierProvider(
            create: (context) => UserDB()
        ),
      ],
      child: MyApp(),
    ),
  );
}