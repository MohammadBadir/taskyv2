import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDB extends ChangeNotifier {
  Map<String,List<int>> courseProgressMap;
  List courseOrder;
  DocumentReference userDocument;
  int debugNum = 0;

  downloadCourseData() async{
    assert(FirebaseAuth.instance.currentUser != null);
    String uid = FirebaseAuth.instance.currentUser.uid;
    userDocument = FirebaseFirestore.instance.collection('testCollection').doc(uid);
    DocumentSnapshot userDB = await userDocument.get();
    try{
      courseOrder = userDB.get('courseOrder');
    } catch (e) {
      courseOrder = ["Initial Value"];
      await userDocument.update({'courseOrder' : courseOrder});
    }
  }

  addWord(String word) async{
    assert(FirebaseAuth.instance.currentUser != null);
    assert(courseOrder != null);
    assert(userDocument != null);
    debugNum++;
    courseOrder.add(word+debugNum.toString());
    print(courseOrder);
    await userDocument.update({'courseOrder' : courseOrder});
    notifyListeners();
  }
}