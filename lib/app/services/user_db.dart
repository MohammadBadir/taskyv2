import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasky/app/models/course_options.dart';

class UserDB extends ChangeNotifier {
  //Map<String,Map<String,List<int>>> courseProgressMap;
  Map courseProgressMap;
  List courseOrder;
  DocumentReference userDocument;
  int debugNum = 0;

  downloadCourseData() async{
    print("Download");
    assert(FirebaseAuth.instance.currentUser != null);
    String uid = FirebaseAuth.instance.currentUser.uid;
    userDocument = FirebaseFirestore.instance.collection('testCollection').doc(uid);
    DocumentSnapshot userSnapshot;
    try{
      userSnapshot = await userDocument.get();
    } catch(e){
      userDocument.set({});
      userSnapshot = await userDocument.get();
    }

    try{
      courseOrder = userSnapshot.get('courseOrder');
      courseProgressMap = userSnapshot.get('courseProgressMap');
    } catch (e) {
      courseOrder = [];
      courseProgressMap = {};
      await userDocument.set({'courseOrder' : courseOrder,'courseProgressMap' : courseProgressMap});
    }
  }

  updateProgressMap(Map newMap){
    courseProgressMap = newMap;
    userDocument.update({'courseProgressMap' : courseProgressMap});
    notifyListeners();
    //print("inFunct "+courseProgressMap.toString());
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

  addCourse(String courseName, CourseOptions courseOptions) async{
    assert(FirebaseAuth.instance.currentUser != null);
    assert(courseOrder != null);
    assert(userDocument != null);
    Map tempMap = {};
    if(courseOptions.hasLecture){
      tempMap['Lecture']=[];
    }
    if(courseOptions.hasTutorial){
      tempMap['Tutorial']=[];
    }
    courseProgressMap[courseName]=tempMap;
    courseOrder.add(courseName);
    await userDocument.update({'courseProgressMap' : courseProgressMap});
    await userDocument.update({'courseOrder' : courseOrder});
    notifyListeners();
  }

  int numOfCourseRows(){
    return courseProgressMap.length;
  }
}