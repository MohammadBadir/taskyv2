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
  Map courseGradesMap;
  List homeworkList;

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
    } catch (e){
      courseOrder = [];
      courseProgressMap = {};
      await userDocument.set({'courseOrder' : courseOrder,'courseProgressMap' : courseProgressMap});
    }

    //Backwards compatibility
    try{
      courseGradesMap = userSnapshot.get('courseGradesMap');
      homeworkList = userSnapshot.get('homeworkList');
    } catch(e){
      courseGradesMap = {};
      homeworkList = [];
      await userDocument.update({'courseGradesMap' : courseGradesMap});
      await userDocument.update({'homeworkList' : homeworkList});
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
    Map dataMap = {};
    if(courseOptions.isSingleton){
      dataMap['Singleton']=[];
    } else {
      if(courseOptions.lectureCount>0){
        dataMap['Lecture']=[];
      }
      if(courseOptions.tutorialCount>0){
        dataMap['Tutorial']=[];
      }
      if(courseOptions.workShopCount>0){
        dataMap['Workshop']=[];
      }
    }
    Map infoMap = {
      'lectureCount': courseOptions.lectureCount,
      'tutorialCount': courseOptions.tutorialCount,
      'workshopCount': courseOptions.workShopCount
    };
    courseProgressMap[courseName]= {'info': infoMap, 'data': dataMap};
    courseOrder.add(courseName);
    await userDocument.update({'courseProgressMap' : courseProgressMap});
    await userDocument.update({'courseOrder' : courseOrder});
    notifyListeners();
  }

  addCourseGrade(String courseName, double points, double grade) async{
    courseGradesMap[courseName]=[points,grade];
    await userDocument.update({'courseGradesMap' : courseGradesMap});
    notifyListeners();
  }

  addHomework(String courseName, String hwName, DateTime dueDate){
    homeworkList.add({'courseName' : courseName,'hwName':hwName,'due' : dueDate.millisecondsSinceEpoch});
    userDocument.update({'homeworkList' : homeworkList});
    notifyListeners();
  }

  completeHomework(Map hw){
    homeworkList.remove(hw);
    userDocument.update({'homeworkList' : homeworkList});
    notifyListeners();
  }

  editHomework(Map oldHW, String courseName, String hwName, DateTime dueDate){
    homeworkList.remove(oldHW);
    homeworkList.add({'courseName' : courseName,'hwName':hwName,'due' : dueDate.millisecondsSinceEpoch});
    userDocument.update({'homeworkList' : homeworkList});
    notifyListeners();
  }

  int numOfCourseRows(){
    return courseProgressMap.length;
  }
}