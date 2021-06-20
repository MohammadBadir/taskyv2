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
  // Map courseGradesMap;
  List homeworkList;
  List taskList;

  downloadCourseData() async{
    print("Fetching Data");
    assert(FirebaseAuth.instance.currentUser != null);
    String uid = FirebaseAuth.instance.currentUser.uid;
    userDocument = FirebaseFirestore.instance.collection('testCollection').doc(uid);
    DocumentSnapshot userSnapshot = await userDocument.get();
    if(!userSnapshot.exists){
      courseOrder = [];
      courseProgressMap = {};
      await userDocument.set({'courseOrder' : courseOrder,'courseProgressMap' : courseProgressMap});
    } else {
      Map<String, dynamic> userData = userSnapshot.data();
      courseOrder = userData['courseOrder'];
      courseProgressMap = userData['courseProgressMap'];
    }

    Map<String, dynamic> userData = userSnapshot.data();
    //Backwards compatibility - Task List
    if(!userData.containsKey('taskList')){
      if(userData.containsKey('homeworkList')){
        homeworkList = userData['homeworkList'];
        taskList = homeworkList.map((e) => {'courseName' : e['courseName'],'hwName':e['hwName'],'due' : e['due'], 'taskType' : 'hw'}).toList();
      } else {
        taskList = [];
      }
      await userDocument.update({'taskList' : taskList});
    } else {
      taskList = userData['taskList'];
    }

    await userDocument.update({'lastLogin' : DateTime.now().toString()});
    print("Data Fetched");
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
    if(courseOptions.isSinglton){
      tempMap['Singleton']=[];
    } else {
      if(courseOptions.hasLecture){
        tempMap['Lecture']=[];
      }
      if(courseOptions.hasTutorial){
        tempMap['Tutorial']=[];
      }
    }
    courseProgressMap[courseName]=tempMap;
    courseOrder.add(courseName);
    await userDocument.update({'courseProgressMap' : courseProgressMap});
    await userDocument.update({'courseOrder' : courseOrder});
    notifyListeners();
  }

  // addCourseGrade(String courseName, double points, double grade) async{
  //   courseGradesMap[courseName]=[points,grade];
  //   await userDocument.update({'courseGradesMap' : courseGradesMap});
  //   notifyListeners();
  // }

  addTask(String courseName, String hwName, DateTime dueDate, String taskType){
    taskList.add({'courseName' : courseName,'hwName':hwName,'due' : dueDate.millisecondsSinceEpoch, 'taskType' : taskType});
    userDocument.update({'taskList' : taskList});
    notifyListeners();
  }

  completeTask(Map hw){
    taskList.remove(hw);
    userDocument.update({'taskList' : taskList});
    notifyListeners();
  }

  editTask(Map oldHW, String courseName, String hwName, DateTime dueDate, String taskType){
    taskList.remove(oldHW);
    taskList.add({'courseName' : courseName,'hwName':hwName,'due' : dueDate.millisecondsSinceEpoch, 'taskType' : taskType});
    userDocument.update({'taskList' : taskList});
    notifyListeners();
  }

  int numOfCourseRows(){
    return courseProgressMap.length;
  }
}