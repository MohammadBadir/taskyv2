import 'package:meta/meta.dart';

@immutable
class UserData {
  const UserData({
    @required this.uid,
    this.email,
    this.photoURL,
    this.displayName,
  });

  final String uid;
  final String email;
  final String photoURL;
  final String displayName;
}
