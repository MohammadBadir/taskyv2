import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasky/app/constants/pages.dart';
import 'package:tasky/app/constants/strings.dart';
import 'package:tasky/app/constants/themes.dart';
import 'package:tasky/app/models/course_options.dart';

class UserDB extends ChangeNotifier {
  String displayName;

  List semesterOrder;
  int currentSemester;

  Map progressMapsBySemester;
  Map courseOrderBySemester;

  Map courseProgressMap;
  List courseOrder;

  //Map pendingTaskMapBySemester;
  Map pendingTaskListBySemester;
  List pendingTaskList;
  String deletedTask;
  int deletedTaskIndex;

  List homeworkList;
  Map deletedHomework;
  int deletedHomeworkIndex;

  int selectedTheme;
  int defaultPage;
  Color mainColor;
  Color secondaryColor;

  DocumentReference userDocument;
  bool firstTime;

  int debugNum = 0;

  downloadCourseData() async{
    print("Fetching Data");
    assert(FirebaseAuth.instance.currentUser != null);
    String uid = FirebaseAuth.instance.currentUser.uid;
    userDocument = FirebaseFirestore.instance.collection('testCollection').doc(uid);
    DocumentSnapshot userSnapshot = await userDocument.get();
    if(!userSnapshot.exists){
      //New user - create data
      firstTime=true;

      courseOrder = [];
      courseProgressMap = {};
      pendingTaskList = ["Example Task"];

      semesterOrder = ["Winter 2020-2021"];
      currentSemester = 0;

      progressMapsBySemester = {semesterOrder[currentSemester] : courseProgressMap};
      courseOrderBySemester = {semesterOrder[currentSemester] : courseOrder};
      pendingTaskListBySemester = {semesterOrder[currentSemester] : pendingTaskList};

      homeworkList = [];

      selectedTheme=0;
      defaultPage=0;

      displayName = "User";

      await userDocument.set({
        'courseOrderBySemester' : courseOrderBySemester,
        'progressMapsBySemester' : progressMapsBySemester,
        'pendingTaskListBySemester' : pendingTaskListBySemester,
        'homeworkList' : homeworkList,
        'semesterOrder' : semesterOrder,
        'currentSemester' : currentSemester,
        'theme' : selectedTheme,
        'defaultPage' : defaultPage,
        'displayName' : displayName
      });
    } else {
      //Existing user - fetch data
      firstTime=false;

      Map<String, dynamic> userData = userSnapshot.data();

      courseOrderBySemester = userData['courseOrderBySemester'];
      progressMapsBySemester = userData['progressMapsBySemester'];
      pendingTaskListBySemester = userData['pendingTaskListBySemester'];

      semesterOrder = userData['semesterOrder'];
      currentSemester = userData['currentSemester'];

      courseOrder = courseOrderBySemester[semesterOrder[currentSemester]];
      courseProgressMap = progressMapsBySemester[semesterOrder[currentSemester]];
      pendingTaskList = pendingTaskListBySemester[semesterOrder[currentSemester]];

      homeworkList = userData['homeworkList'];

      selectedTheme = userData['theme'];
      defaultPage = userData['defaultPage'];

      displayName = userData['displayName'];
    }

    mainColor = Themes.colorPalletes[selectedTheme]['main'];
    secondaryColor = Themes.colorPalletes[selectedTheme]['second'];

    userSnapshot = await userDocument.get();
    //Map<String, dynamic> userData = userSnapshot.data();

    await userDocument.update({'zMiscData' : {'lastLogin' : DateTime.now().toString(), 'currentVer' : Strings.version}});
    print("Data Fetched");
  }

  changeTheme(int newTheme){
    assert(newTheme>=0 && newTheme<Themes.colorPalletes.length);
    selectedTheme = newTheme;
    mainColor = Themes.colorPalletes[selectedTheme]['main'];
    secondaryColor = Themes.colorPalletes[selectedTheme]['second'];
    userDocument.update({'theme' : selectedTheme});
    notifyListeners();
  }

  changeDefaultPage(int newPage){
    assert(newPage>=0 && newPage<Pages.pageNames.length);
    defaultPage = newPage;
    userDocument.update({'defaultPage' : defaultPage});
    notifyListeners();
  }

  changeUsername(String newName){
    displayName = newName;
    userDocument.update({'displayName' : displayName});
    notifyListeners();
  }

  // updateProgressMap(Map newMap){
  //   courseProgressMap = newMap;
  //   userDocument.update({'courseProgressMap' : courseProgressMap});
  //   notifyListeners();
  //   //print("inFunct "+courseProgressMap.toString());
  // }

  updateCourses(){
    userDocument.update({'courseOrderBySemester' : courseOrderBySemester});
    userDocument.update({'progressMapsBySemester' : progressMapsBySemester});
    notifyListeners();
  }

  // addSemester(String title){
  //   assert(!semesterOrder.contains(title));
  //
  // }

  changeSemester(int targetSemester){
    if(currentSemester!=targetSemester){
      currentSemester = targetSemester;
      notifyListeners();
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

  addPendingTask(String task){
    pendingTaskList.add(task);
    userDocument.update({'pendingTaskListBySemester' : pendingTaskListBySemester});
    notifyListeners();
  }

  editPendingTask(String oldTask, String newTask){
    int index = pendingTaskList.indexOf(oldTask);
    pendingTaskList.removeAt(index);
    pendingTaskList.insert(index, newTask);
    userDocument.update({'pendingTaskListBySemester' : pendingTaskListBySemester});
    notifyListeners();
  }

  swapPendingTaskOrder(int newIndex, int oldIndex){
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    var pair = pendingTaskList.removeAt(oldIndex);
    pendingTaskList.insert(newIndex, pair);
    userDocument.update({'pendingTaskListBySemester' : pendingTaskListBySemester});
    notifyListeners();
  }

  completePendingTask(int index){
    deletedTask = pendingTaskList[index];
    deletedTaskIndex = index;
    pendingTaskList.removeAt(index);
    userDocument.update({'pendingTaskListBySemester' : pendingTaskListBySemester});
    notifyListeners();
  }

  undoCompletePendingTask(){
    pendingTaskList.insert(deletedTaskIndex, deletedTask);
    userDocument.update({'pendingTaskListBySemester' : pendingTaskListBySemester});
    notifyListeners();
  }

  addCourse(String courseName, CourseOptions courseOptions){
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
    updateCourses();
  }

  editCourse(String courseName, String newCourseName, CourseOptions newCourseOptions){
    bool changesMade = false;
    bool nameChanged = false;
    CourseOptions courseOptionsFromInfo(Map courseInfo){
      CourseOptions options = CourseOptions();
      options.lectureCount = courseInfo['lectureCount'];
      options.tutorialCount = courseInfo['tutorialCount'];
      options.workShopCount = courseInfo['workshopCount'];
      if(options.lectureCount + options.tutorialCount + options.workShopCount == 0) {
        options.isSingleton = true;
      }
      return options;
    }
    Map courseMap = courseProgressMap[courseName];
    CourseOptions oldCourseOptions = courseOptionsFromInfo(courseMap["info"]);
    Map courseData = courseMap['data'];
    if(oldCourseOptions.lectureCount!=newCourseOptions.lectureCount){
      changesMade = true;
      if(newCourseOptions.lectureCount==0){
        courseData.remove(Strings.lecture);
      } else if(oldCourseOptions.lectureCount==0 && newCourseOptions.lectureCount>0){
        courseData[Strings.lecture]=[];
      } else if(oldCourseOptions.lectureCount>newCourseOptions.lectureCount){
        courseData[Strings.lecture].clear();
      }
    }
    if(oldCourseOptions.tutorialCount!=newCourseOptions.tutorialCount){
      changesMade = true;
      if(newCourseOptions.tutorialCount==0){
        courseData.remove(Strings.tutorial);
      } else if(oldCourseOptions.tutorialCount==0 && newCourseOptions.tutorialCount>0){
        courseData[Strings.tutorial]=[];
      } else if(oldCourseOptions.tutorialCount>newCourseOptions.tutorialCount){
        courseData[Strings.tutorial].clear();
      }
    }
    if(oldCourseOptions.workShopCount!=newCourseOptions.workShopCount){
      changesMade = true;
      if(newCourseOptions.workShopCount==0){
        courseData.remove(Strings.workshop);
      } else if(oldCourseOptions.workShopCount==0 && newCourseOptions.workShopCount>0){
        courseData[Strings.workshop]=[];
      } else if(oldCourseOptions.workShopCount>newCourseOptions.workShopCount){
        courseData[Strings.workshop].clear();
      }
    }
    Map newInfoMap = {
      'lectureCount': newCourseOptions.lectureCount,
      'tutorialCount': newCourseOptions.tutorialCount,
      'workshopCount': newCourseOptions.workShopCount
    };
    courseMap["info"] = newInfoMap;
    if(newCourseName!=courseName){
      changesMade = true;
      nameChanged = true;
      courseProgressMap[newCourseName] = courseMap;
      courseProgressMap.remove(courseName);
      List newHWList = [];
      homeworkList.forEach((element) {
        if(element['courseName']!=courseName){
          newHWList.add(element);
        } else {
          newHWList.add({'courseName':newCourseName, 'hwName':element['hwName'], 'due':element['due'], 'taskType':element['taskType']});
        }
      });
      homeworkList=newHWList;
    }
    int index = courseOrder.indexOf(courseName);
    courseOrder.removeAt(index);
    courseOrder.insert(index, newCourseName);
    if(changesMade){
      updateCourses();
      if(nameChanged){
        userDocument.update({'homeworkList' : homeworkList});
      }
    }
  }

  swapCourseOrder(int newIndex, int oldIndex){
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    var pair = courseOrder.removeAt(oldIndex);
    courseOrder.insert(newIndex, pair);
    updateCourses();
  }

  deleteCourse(int index){
    String courseName = courseOrder[index];
    courseOrder.removeAt(index);
    courseProgressMap.remove(courseName);
    homeworkList.removeWhere((element) => element['courseName']==courseName);
    updateCourses();
    userDocument.update({'homeworkList' : homeworkList});
  }

  // addCourseGrade(String courseName, double points, double grade) async{
  //   courseGradesMap[courseName]=[points,grade];
  //   await userDocument.update({'courseGradesMap' : courseGradesMap});
  //   notifyListeners();
  // }

  addHomework(String courseName, String hwName, DateTime dueDate, String taskType){
    // if(homeworkList.any((element) => element['courseName']==courseName && element['hwName']==hwName && element['taskType']==taskType)){
    //   return false;
    // }
    homeworkList.add({'courseName' : courseName,'hwName':hwName,'due' : dueDate.millisecondsSinceEpoch, 'taskType' : taskType});
    userDocument.update({'homeworkList' : homeworkList});
    notifyListeners();
    //TODO: don't allow duplicates...
  }

  completeHomework(int index){
    deletedHomeworkIndex = index;
    deletedHomework = homeworkList[index];
    homeworkList.removeAt(index);
    userDocument.update({'homeworkList' : homeworkList});
    notifyListeners();
  }

  undoCompleteHomework(){
    homeworkList.insert(deletedHomeworkIndex, deletedHomework);
    userDocument.update({'homeworkList' : homeworkList});
    notifyListeners();
  }

  String completeHomeworkMessage(int index){
    List sortedTaskList = homeworkList;
    sortedTaskList.sort((var a, var b) => a['due'].compareTo(b['due']));
    var currentTime = DateTime.now();
    int timeDiff(int index) => DateTime.fromMillisecondsSinceEpoch(sortedTaskList[index]['due']).difference(DateTime(currentTime.year,currentTime.month,currentTime.day)).inDays;
    if(homeworkList[index]['taskType']=='exam'){
      return "Exam marked as complete";
    } else {
      if(timeDiff(index)>=0){
        return "Homework marked as complete";
      } else {
        return "Homework archived";
      }
    }
  }

  editTask(Map oldHW, String courseName, String hwName, DateTime dueDate, String taskType){
    homeworkList.remove(oldHW);
    homeworkList.add({'courseName' : courseName,'hwName':hwName,'due' : dueDate.millisecondsSinceEpoch, 'taskType' : taskType});
    userDocument.update({'homeworkList' : homeworkList});
    notifyListeners();
  }

  int numOfCourseRows(){
    return courseProgressMap.length;
  }
}