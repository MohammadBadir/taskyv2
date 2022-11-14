import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/constants/pages.dart';
import 'package:tasky/app/constants/strings.dart';
import 'package:tasky/app/constants/themes.dart';
import 'package:tasky/app/logic/enums.dart';
import 'package:tasky/app/models/course_options.dart';

class UserDB extends ChangeNotifier {
  String displayName;

  List semesterOrder;
  int currentSemester;

  //TODO: Migration of semester class arrays to 13-length array model with enums, simplifies most code since marking order is irrelevant
  Map progressMapsBySemester;
  Map courseOrderBySemester;

  Map courseProgressMap;
  Map backupCourseProgressMap;
  List courseOrder;

  //Map pendingTaskMapBySemester;
  Map pendingTaskListBySemester;
  List pendingTaskList;
  String deletedTask;
  int deletedTaskIndex;

  Map homeworkListBySemester;
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

  //non-db stored data
  Map<int, Map<String, Map<String, CellStatus>>> backupMap = {}; // weekIndex -> courseName -> fieldType (lec/tut/wrk) -> FieldType

  downloadCourseData() async {
    print("Fetching Data");
    assert(FirebaseAuth.instance.currentUser != null);
    String uid = FirebaseAuth.instance.currentUser.uid;
    userDocument =
        FirebaseFirestore.instance.collection('testCollection').doc(uid);
    DocumentSnapshot userSnapshot = await userDocument.get();
    if (!userSnapshot.exists) {
      //New user - create data
      firstTime = true;

      courseOrder = [];
      courseProgressMap = {};
      pendingTaskList = ["Example Task"];

      semesterOrder = ["Winter 22-23"];
      currentSemester = 0;
      homeworkList = [];

      progressMapsBySemester =
      {semesterOrder[currentSemester]: courseProgressMap};
      courseOrderBySemester = {semesterOrder[currentSemester]: courseOrder};
      pendingTaskListBySemester = {'Winter 2020-2021': pendingTaskList};
      homeworkListBySemester = {semesterOrder[currentSemester]: homeworkList};

      selectedTheme = 0;
      defaultPage = 0;

      displayName = "User";

      await userDocument.set({
        'courseOrderBySemester': courseOrderBySemester,
        'progressMapsBySemester': progressMapsBySemester,
        'pendingTaskListBySemester': pendingTaskListBySemester,
        'homeworkListBySemester': homeworkListBySemester,
        'semesterOrder': semesterOrder,
        'currentSemester': currentSemester,
        'theme': selectedTheme,
        'defaultPage': defaultPage,
        'displayName': displayName
      });
    } else {
      //Existing user - fetch data
      firstTime = false;

      Map<String, dynamic> userData = userSnapshot.data();

      courseOrderBySemester = userData['courseOrderBySemester'];
      progressMapsBySemester = userData['progressMapsBySemester'];
      pendingTaskListBySemester = userData['pendingTaskListBySemester'];
      homeworkListBySemester = userData['homeworkListBySemester'];

      //backwards compatibility
      if (homeworkListBySemester == null) {
        homeworkList = userData['homeworkList'];
        homeworkListBySemester = {'Winter 2020-2021': homeworkList};
        userDocument.update({'homeworkListBySemester': homeworkListBySemester});
      }

      semesterOrder = userData['semesterOrder'];
      currentSemester = userData['currentSemester'];

      //Bugfix - Up to v0.4.7, deleting semester did not correctly update currentSemester variable
      if(currentSemester>=semesterOrder.length){
        currentSemester = 0;
      }

      courseOrder = courseOrderBySemester[semesterOrder[currentSemester]];
      courseProgressMap =
      progressMapsBySemester[semesterOrder[currentSemester]];
      pendingTaskList = pendingTaskListBySemester['Winter 2020-2021'];
      homeworkList = homeworkListBySemester[semesterOrder[currentSemester]];

      selectedTheme = userData['theme'];
      defaultPage = userData['defaultPage'];

      displayName = userData['displayName'];
    }

    mainColor = Themes.colorPalletes[selectedTheme]['main'];
    secondaryColor = Themes.colorPalletes[selectedTheme]['second'];

    userSnapshot = await userDocument.get();
    //Map<String, dynamic> userData = userSnapshot.data();

    await userDocument.update({
      'zMiscData': {
        'lastLogin': DateTime.now().toString(),
        'currentVer': Strings.version
      }
    });
    print("Data Fetched");
  }

  changeTheme(int newTheme) {
    assert(newTheme >= 0 && newTheme < Themes.colorPalletes.length);
    selectedTheme = newTheme;
    mainColor = Themes.colorPalletes[selectedTheme]['main'];
    secondaryColor = Themes.colorPalletes[selectedTheme]['second'];
    userDocument.update({'theme': selectedTheme});
    notifyListeners();
  }

  changeDefaultPage(int newPage) {
    assert(newPage >= 0 && newPage < Pages.pageNames.length);
    defaultPage = newPage;
    userDocument.update({'defaultPage': defaultPage});
    notifyListeners();
  }

  changeUsername(String newName) {
    displayName = newName;
    userDocument.update({'displayName': displayName});
    notifyListeners();
  }

  // updateProgressMap(Map newMap){
  //   courseProgressMap = newMap;
  //   userDocument.update({'courseProgressMap' : courseProgressMap});
  //   notifyListeners();
  //   //print("inFunct "+courseProgressMap.toString());
  // }

  updateCourses() {
    userDocument.update({'courseOrderBySemester': courseOrderBySemester});
    userDocument.update({'progressMapsBySemester': progressMapsBySemester});
    notifyListeners();
  }

  // addSemester(String title){
  //   assert(!semesterOrder.contains(title));
  //
  // }

  /**
   * Legacy function - unused
   */
  addWord(String word) async {
    assert(FirebaseAuth.instance.currentUser != null);
    assert(courseOrder != null);
    assert(userDocument != null);
    debugNum++;
    courseOrder.add(word + debugNum.toString());
    print(courseOrder);
    await userDocument.update({'courseOrder': courseOrder});
    notifyListeners();
  }

  addPendingTask(String task) {
    pendingTaskList.add(task);
    userDocument.update(
        {'pendingTaskListBySemester': pendingTaskListBySemester});
    notifyListeners();
  }

  editPendingTask(String oldTask, String newTask) {
    int index = pendingTaskList.indexOf(oldTask);
    pendingTaskList.removeAt(index);
    pendingTaskList.insert(index, newTask);
    userDocument.update(
        {'pendingTaskListBySemester': pendingTaskListBySemester});
    notifyListeners();
  }

  swapPendingTaskOrder(int newIndex, int oldIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    var pair = pendingTaskList.removeAt(oldIndex);
    pendingTaskList.insert(newIndex, pair);
    userDocument.update(
        {'pendingTaskListBySemester': pendingTaskListBySemester});
    notifyListeners();
  }

  completePendingTask(int index) {
    deletedTask = pendingTaskList[index];
    deletedTaskIndex = index;
    pendingTaskList.removeAt(index);
    userDocument.update(
        {'pendingTaskListBySemester': pendingTaskListBySemester});
    notifyListeners();
  }

  undoCompletePendingTask() {
    pendingTaskList.insert(deletedTaskIndex, deletedTask);
    userDocument.update(
        {'pendingTaskListBySemester': pendingTaskListBySemester});
    notifyListeners();
  }

  addCourse(String courseName, CourseOptions courseOptions) {
    assert(FirebaseAuth.instance.currentUser != null);
    assert(courseOrder != null);
    assert(userDocument != null);
    Map dataMap = {};
    if (courseOptions.isSingleton) {
      dataMap['Singleton'] = [];
    } else {
      if (courseOptions.lectureCount > 0) {
        dataMap['Lecture'] = [];
      }
      if (courseOptions.tutorialCount > 0) {
        dataMap['Tutorial'] = [];
      }
      if (courseOptions.workShopCount > 0) {
        dataMap['Workshop'] = [];
      }
    }
    Map infoMap = {
      'lectureCount': courseOptions.lectureCount,
      'tutorialCount': courseOptions.tutorialCount,
      'workshopCount': courseOptions.workShopCount
    };
    courseProgressMap[courseName] = {'info': infoMap, 'data': dataMap};
    courseOrder.add(courseName);
    updateCourses();
  }

  editCourse(String courseName, String newCourseName,
      CourseOptions newCourseOptions) {
    bool changesMade = false;
    bool nameChanged = false;

    Map courseMap = courseProgressMap[courseName];
    CourseOptions oldCourseOptions = CourseOptions.fromInfoMap(courseMap["info"]);
    Map courseData = courseMap['data'];
    if (oldCourseOptions.lectureCount != newCourseOptions.lectureCount) {
      changesMade = true;
      if (newCourseOptions.lectureCount == 0) {
        courseData.remove(Strings.lecture);
      } else if (oldCourseOptions.lectureCount == 0 &&
          newCourseOptions.lectureCount > 0) {
        courseData[Strings.lecture] = [];
      } else
      if (oldCourseOptions.lectureCount > newCourseOptions.lectureCount) {
        courseData[Strings.lecture].clear();
      }
    }
    if (oldCourseOptions.tutorialCount != newCourseOptions.tutorialCount) {
      changesMade = true;
      if (newCourseOptions.tutorialCount == 0) {
        courseData.remove(Strings.tutorial);
      } else if (oldCourseOptions.tutorialCount == 0 &&
          newCourseOptions.tutorialCount > 0) {
        courseData[Strings.tutorial] = [];
      } else
      if (oldCourseOptions.tutorialCount > newCourseOptions.tutorialCount) {
        courseData[Strings.tutorial].clear();
      }
    }
    if (oldCourseOptions.workShopCount != newCourseOptions.workShopCount) {
      changesMade = true;
      if (newCourseOptions.workShopCount == 0) {
        courseData.remove(Strings.workshop);
      } else if (oldCourseOptions.workShopCount == 0 &&
          newCourseOptions.workShopCount > 0) {
        courseData[Strings.workshop] = [];
      } else
      if (oldCourseOptions.workShopCount > newCourseOptions.workShopCount) {
        courseData[Strings.workshop].clear();
      }
    }
    Map newInfoMap = {
      'lectureCount': newCourseOptions.lectureCount,
      'tutorialCount': newCourseOptions.tutorialCount,
      'workshopCount': newCourseOptions.workShopCount,
      'isHidden' : oldCourseOptions.isHidden
    };
    courseMap["info"] = newInfoMap;
    if (newCourseName != courseName) {
      changesMade = true;
      nameChanged = true;
      courseProgressMap[newCourseName] = courseMap;
      courseProgressMap.remove(courseName);
      List newHWList = [];
      homeworkList.forEach((element) {
        if (element['courseName'] != courseName) {
          newHWList.add(element);
        } else {
          newHWList.add({
            'courseName': newCourseName,
            'hwName': element['hwName'],
            'due': element['due'],
            'taskType': element['taskType']
          });
        }
      });
      homeworkList = newHWList;
    }
    int index = courseOrder.indexOf(courseName);
    courseOrder.removeAt(index);
    courseOrder.insert(index, newCourseName);
    if (changesMade) {
      updateCourses();
      if (nameChanged) {
        userDocument.update({'homeworkListBySemester': homeworkListBySemester});
      }
    }
  }

  swapCourseOrder(int newIndex, int oldIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    var pair = courseOrder.removeAt(oldIndex);
    courseOrder.insert(newIndex, pair);
    updateCourses();
  }

  deleteCourse(int index) {
    String courseName = courseOrder[index];
    courseOrder.removeAt(index);
    courseProgressMap.remove(courseName);
    homeworkList.removeWhere((element) => element['courseName'] == courseName);
    updateCourses();
    userDocument.update({'homeworkListBySemester': homeworkListBySemester});
  }

  // addCourseGrade(String courseName, double points, double grade) async{
  //   courseGradesMap[courseName]=[points,grade];
  //   await userDocument.update({'courseGradesMap' : courseGradesMap});
  //   notifyListeners();
  // }

  addHomework(String courseName, String hwName, DateTime dueDate,
      String taskType) {
    // if(homeworkList.any((element) => element['courseName']==courseName && element['hwName']==hwName && element['taskType']==taskType)){
    //   return false;
    // }
    homeworkList.add({
      'courseName': courseName,
      'hwName': hwName,
      'due': dueDate.millisecondsSinceEpoch,
      'taskType': taskType
    });
    userDocument.update({'homeworkListBySemester': homeworkListBySemester});
    notifyListeners();
    //TODO: don't allow duplicates...
  }

  completeHomework(int index) {
    deletedHomeworkIndex = index;
    deletedHomework = homeworkList[index];
    homeworkList.removeAt(index);
    userDocument.update({'homeworkListBySemester': homeworkListBySemester});
    notifyListeners();
  }

  undoCompleteHomework() {
    homeworkList.insert(deletedHomeworkIndex, deletedHomework);
    userDocument.update({'homeworkListBySemester': homeworkListBySemester});
    notifyListeners();
  }

  String completeHomeworkMessage(int index) {
    List sortedTaskList = homeworkList;
    sortedTaskList.sort((var a, var b) => a['due'].compareTo(b['due']));
    var currentTime = DateTime.now();
    int timeDiff(int index) =>
        DateTime
            .fromMillisecondsSinceEpoch(sortedTaskList[index]['due'])
            .difference(
            DateTime(currentTime.year, currentTime.month, currentTime.day))
            .inDays;
    if (homeworkList[index]['taskType'] == 'exam') {
      return "Exam marked as complete";
    } else {
      if (timeDiff(index) >= 0) {
        return "Homework marked as complete";
      } else {
        return "Homework archived";
      }
    }
  }

  editTask(Map oldHW, String courseName, String hwName, DateTime dueDate,
      String taskType) {
    homeworkList.remove(oldHW);
    homeworkList.add({
      'courseName': courseName,
      'hwName': hwName,
      'due': dueDate.millisecondsSinceEpoch,
      'taskType': taskType
    });
    userDocument.update({'homeworkListBySemester': homeworkListBySemester});
    notifyListeners();
  }

  int numOfCourseRows() {
    return courseProgressMap.length;
  }

  addSemester(String semesterName) {
    semesterOrder.add(semesterName);
    progressMapsBySemester[semesterName] = {};
    courseOrderBySemester[semesterName] = [];
    homeworkListBySemester[semesterName] = [];
    userDocument.update({
      'semesterOrder': semesterOrder,
      'courseOrderBySemester': courseOrderBySemester,
      'progressMapsBySemester': progressMapsBySemester,
      'homeworkListBySemester': homeworkListBySemester
    });
    notifyListeners();
  }

  changeSemester(int targetSemester) {
    if (currentSemester != targetSemester) {
      currentSemester = targetSemester;
      courseOrder = courseOrderBySemester[semesterOrder[currentSemester]];
      courseProgressMap =
      progressMapsBySemester[semesterOrder[currentSemester]];
      homeworkList = homeworkListBySemester[semesterOrder[currentSemester]];
      userDocument.update({'currentSemester': currentSemester});
      notifyListeners();
    }
  }

  renameSemester(int index, String newName) {
    String oldName = semesterOrder[index];
    semesterOrder.removeAt(index);
    semesterOrder.insert(index, newName);
    progressMapsBySemester[newName] = progressMapsBySemester[oldName];
    progressMapsBySemester.remove(oldName);
    courseOrderBySemester[newName] = courseOrderBySemester[oldName];
    courseOrderBySemester.remove(oldName);
    homeworkListBySemester[newName] = homeworkListBySemester[oldName];
    homeworkListBySemester.remove(oldName);
    userDocument.update({
      'semesterOrder': semesterOrder,
      'courseOrderBySemester': courseOrderBySemester,
      'progressMapsBySemester': progressMapsBySemester,
      'homeworkListBySemester': homeworkListBySemester
    });
    notifyListeners();
  }

  deleteSemester(int index) {
    String name = semesterOrder[index];
    semesterOrder.removeAt(index);
    progressMapsBySemester.remove(name);
    courseOrderBySemester.remove(name);
    homeworkListBySemester.remove(name);

    if(currentSemester>index){
      currentSemester--;
    }

    userDocument.update({
      'currentSemester' : currentSemester,
      'semesterOrder': semesterOrder,
      'courseOrderBySemester': courseOrderBySemester,
      'progressMapsBySemester': progressMapsBySemester,
      'homeworkListBySemester': homeworkListBySemester
    });
    notifyListeners();
  }

  /**
   * Mark completed cell
   */
  standardUpdateCourseProgress(Map courseData, String fieldName, int numWeeks,
      int count, int index) {
    //TODO: Logic is very messy, organize it...
    int weekIndex = (index - 3) ~/ 2;

    if (courseData[fieldName].contains(weekIndex)) {
      courseData[fieldName].remove(weekIndex);
      if (count == 2) courseData[fieldName].add(weekIndex + numWeeks);
    } else if (courseData[fieldName].contains(weekIndex + numWeeks)) {
      courseData[fieldName].remove(weekIndex + numWeeks);
    } else if (courseData[fieldName].contains(-weekIndex)) {
      courseData[fieldName].remove(-weekIndex);
      courseData[fieldName].add(weekIndex);
    } else {
      courseData[fieldName].add(weekIndex);
    }
    updateCourses();
  }

  /**
   * Mark pending cell
   */
  pendingUpdateCourseProgress(Map courseData, String fieldName, int numWeeks,
      int index) {
    int weekIndex = (index - 3) ~/ 2;
    if (!courseData[fieldName].contains(-weekIndex)) {
      courseData[fieldName].remove(weekIndex);
      courseData[fieldName].remove(weekIndex + numWeeks);
      courseData[fieldName].add(-weekIndex);
    } else {
      courseData[fieldName].remove(-weekIndex);
    }
    updateCourses();
  }

  /**
   * Clears all markings from all courses (including hidden).
   */
  clearAllCourses(){
    int numWeeks = 13;
    for (String courseName in courseOrder) {
      Map courseMap = courseProgressMap[courseName];
      Map courseData = courseMap['data'];
      Map courseInfo = courseMap['info'];
      List<String> fieldNames = [];
      int lectureCount = courseInfo['lectureCount'];
      int tutorialCount = courseInfo['tutorialCount'];
      int workShopCount = courseInfo['workshopCount'];
      if(lectureCount>0){
        fieldNames.add(Strings.lecture);
      }
      if(tutorialCount>0){
        fieldNames.add(Strings.tutorial);
      }
      if(workShopCount>0){
        fieldNames.add(Strings.workshop);
      }
      for (String fieldName in fieldNames) {
        courseData[fieldName].clear();
      }
    }
    updateCourses();
  }

  /**
   * Delete all courses in the currently selected semester (including hidden ones).
   */
  deleteAllCourses(){
    while(courseOrder.isNotEmpty){
      deleteCourse(0);
    }
  }

  //WEEK ACTIONS

  /**
   * Adds a pending week to all (including hidden) courses in all categories.
   */
  addPendingWeekInAllCourses() {
    int numWeeks = 13;
    //TODO: Add backup
    for (String courseName in courseOrder) {
      Map courseMap = courseProgressMap[courseName];
      Map courseData = courseMap['data'];
      Map courseInfo = courseMap['info'];
      List<String> fieldNames = [];
      int lectureCount = courseInfo['lectureCount'];
      int tutorialCount = courseInfo['tutorialCount'];
      int workShopCount = courseInfo['workshopCount'];
      if(lectureCount>0){
        fieldNames.add(Strings.lecture);
      }
      if(tutorialCount>0){
        fieldNames.add(Strings.tutorial);
      }
      if(workShopCount>0){
        fieldNames.add(Strings.workshop);
      }
      for (String fieldName in fieldNames) {
        List fieldList = courseData[fieldName];
        int index;
        for (index = 5; index < 31; index += 2) {
          if(!fieldList.contains((index - 3) ~/ 2) && !fieldList.contains(-(index - 3) ~/ 2) && !fieldList.contains((index - 3) ~/ 2 + numWeeks)){
            break;
          }
        }
        if (index < 31) {
          fieldList.add(-(index - 3) ~/ 2);
        }
      }
    }
    updateCourses();
  }

  /**
   * Marks a completed week in all (including hidden) courses in all categories.
   */
  addCompletedWeekInAllCourses(){
    int numWeeks = 13;
    for (String courseName in courseOrder) {
      Map courseMap = courseProgressMap[courseName];
      Map courseData = courseMap['data'];
      Map courseInfo = courseMap['info'];
      List<String> fieldNames = [];
      int lectureCount = courseInfo['lectureCount'];
      int tutorialCount = courseInfo['tutorialCount'];
      int workShopCount = courseInfo['workshopCount'];
      if(lectureCount>0){
        fieldNames.add(Strings.lecture);
      }
      if(tutorialCount>0){
        fieldNames.add(Strings.tutorial);
      }
      if(workShopCount>0){
        fieldNames.add(Strings.workshop);
      }
      for (String fieldName in fieldNames) {
        List fieldList = courseData[fieldName];
        int count;
        if(fieldName == Strings.lecture){
          count = lectureCount;
        } else if(fieldName == Strings.tutorial){
          count = tutorialCount;
        } else {
          count = workShopCount;
        }
        int index;
        for (index = 5; index < 31; index += 2) {
          if(count==2){
            if(!fieldList.contains((index - 3) ~/ 2 + numWeeks)){
              fieldList.remove((index - 3) ~/ 2);
              break;
            }
          } else {
            if(!fieldList.contains((index - 3) ~/ 2)){
              break;
            }
          }
        }
        if(index < 31) {
          if(count==2){
            fieldList.add((index - 3) ~/ 2 + numWeeks);
          } else {
            fieldList.add((index - 3) ~/ 2);
          }
        }
      }
    }
    updateCourses();
  }

  /**
   * Marks an entire week as pending, in all unhidden courses. Skips completed weeks.
   * If all courses are already pending, the week is cleared.
   * If
   */
  markWeekAsPending(BuildContext context, int index){
    //TODO: Get rid of index parameter syntax
    int numWeeks = 13;
    int weekIndex = ((index - 3) ~/ 2);

    _storeBackup(weekIndex);

    bool foundUnmarkedWeek = false, foundMarkedWeek = false, foundCompletedWeek = false;
    for (String courseName in courseOrder) {
      Map courseMap = courseProgressMap[courseName];
      Map courseData = courseMap['data'];
      Map courseInfo = courseMap['info'];
      var courseOptions = CourseOptions.fromInfoMap(courseInfo);

      if(courseOptions.isHidden){
        continue;
      }

      List<String> fieldNames = [];
      int lectureCount = courseOptions.lectureCount;
      int tutorialCount = courseOptions.tutorialCount;
      int workShopCount = courseOptions.workShopCount;

      if(lectureCount>0){
        fieldNames.add(Strings.lecture);
      }
      if(tutorialCount>0){
        fieldNames.add(Strings.tutorial);
      }
      if(workShopCount>0){
        fieldNames.add(Strings.workshop);
      }
      for (String fieldName in fieldNames) {
        List fieldList = courseData[fieldName];
        if(fieldList.contains(weekIndex) || fieldList.contains(weekIndex + numWeeks)){
          foundCompletedWeek = true;
          continue;
        }
        if(!fieldList.contains(-weekIndex)){
          fieldList.add(-weekIndex);
          foundUnmarkedWeek = true;
        } else {
          foundMarkedWeek = true;
        }
      }
    }
    bool allWeeksArePending = !foundCompletedWeek && !foundUnmarkedWeek;
    bool allWeeksAreCompleted = !foundMarkedWeek && !foundUnmarkedWeek;
    bool mixOfPendingAndCompleted = foundMarkedWeek && foundCompletedWeek && !foundUnmarkedWeek;

    if(allWeeksAreCompleted || allWeeksArePending){
      clearWeek(weekIndex);
      _showClearedWeekSnackBar(context, weekIndex);
    } else if(mixOfPendingAndCompleted){
      _clearPendingInColumn(weekIndex);
      _showClearedAllPendingInWeekSnackBar(context, weekIndex);
    } else {
      updateCourses();
      _showPendingWeekSnackBar(context, weekIndex);
    }
  }

  /**
   * Marks an entire week as complete, in all unhidden courses, including double weeks.
   * If all courses are already completed, the week is cleared.
   */
  markWeekAsComplete(BuildContext context, int index){

    //TODO: Get rid of index parameter syntax
    int numWeeks = 13;
    int weekIndex = ((index - 3) ~/ 2);

    _storeBackup(weekIndex);

    bool foundUnmarkedWeek = false;
    for (String courseName in courseOrder) {
      Map courseMap = courseProgressMap[courseName];
      Map courseData = courseMap['data'];
      Map courseInfo = courseMap['info'];

      var courseOptions = CourseOptions.fromInfoMap(courseInfo);

      if(courseOptions.isHidden){
        continue;
      }

      List<String> fieldNames = [];
      int lectureCount = courseOptions.lectureCount;
      int tutorialCount = courseOptions.tutorialCount;
      int workShopCount = courseOptions.workShopCount;

      if(lectureCount>0){
        fieldNames.add(Strings.lecture);
      }
      if(tutorialCount>0){
        fieldNames.add(Strings.tutorial);
      }
      if(workShopCount>0){
        fieldNames.add(Strings.workshop);
      }
      for (String fieldName in fieldNames) {
        List fieldList = courseData[fieldName];
        int count;

        if(fieldName == Strings.lecture){
          count = lectureCount;
        } else if(fieldName == Strings.tutorial){
          count = tutorialCount;
        } else {
          count = workShopCount;
        }

        if(fieldList.contains(-weekIndex)){
          fieldList.remove(-weekIndex);
        }

        if(count==1 && !fieldList.contains(weekIndex)){
          fieldList.add(weekIndex);
          foundUnmarkedWeek = true;
        }

        if(count==2 && fieldList.contains(weekIndex)){
          fieldList.remove(weekIndex);
        }

        if(count==2 && !fieldList.contains(weekIndex+numWeeks)){
          fieldList.add(weekIndex+numWeeks);
          foundUnmarkedWeek = true;
        }
      }
    }
    if(!foundUnmarkedWeek){
      clearWeek(weekIndex);
      _showClearedWeekSnackBar(context, weekIndex);
    } else {
      updateCourses();
      _showCompletedWeekSnackBar(context, weekIndex);
    }
  }

  /**
   *
   */
  _clearPendingInColumn(int weekIndex){
    int numOfWeeks = 13;

    for (String courseName in courseOrder) {
      Map courseMap = courseProgressMap[courseName];
      Map courseData = courseMap['data'];
      Map courseInfo = courseMap['info'];
      var courseOptions = CourseOptions.fromInfoMap(courseInfo);

      if(courseOptions.isHidden){
        continue;
      }

      List<String> fieldNames = [];
      int lectureCount = courseOptions.lectureCount;
      int tutorialCount = courseOptions.tutorialCount;
      int workShopCount = courseOptions.workShopCount;

      if(lectureCount>0){
        fieldNames.add(Strings.lecture);
      }
      if(tutorialCount>0){
        fieldNames.add(Strings.tutorial);
      }
      if(workShopCount>0){
        fieldNames.add(Strings.workshop);
      }
      for (String fieldName in fieldNames) {
        List fieldList = courseData[fieldName];
        fieldList.remove(-weekIndex);
      }
    }
    updateCourses();
  }

  /**
   * Clears all markings in the given week, in all unhidden courses.
   */
  clearWeek(int weekIndex){
    int numOfWeeks = 13;

    for (String courseName in courseOrder) {
      Map courseMap = courseProgressMap[courseName];
      Map courseData = courseMap['data'];
      Map courseInfo = courseMap['info'];
      var courseOptions = CourseOptions.fromInfoMap(courseInfo);

      if(courseOptions.isHidden){
        continue;
      }

      List<String> fieldNames = [];
      int lectureCount = courseOptions.lectureCount;
      int tutorialCount = courseOptions.tutorialCount;
      int workShopCount = courseOptions.workShopCount;

      if(lectureCount>0){
        fieldNames.add(Strings.lecture);
      }
      if(tutorialCount>0){
        fieldNames.add(Strings.tutorial);
      }
      if(workShopCount>0){
        fieldNames.add(Strings.workshop);
      }
      for (String fieldName in fieldNames) {
        List fieldList = courseData[fieldName];
        fieldList.remove(-weekIndex);
        fieldList.remove(weekIndex);
        fieldList.remove(weekIndex+numOfWeeks);
      }
    }
    updateCourses();
  }

  //HIDDEN COURSES

  /***
   * returns true iff the given course is marked as hidden in its infoMap
   */
  bool isHiddenCourse(String courseName){
    Map courseMap = courseProgressMap[courseName];
    CourseOptions courseOptions = CourseOptions.fromInfoMap(courseMap["info"]);
    return courseOptions.isHidden;
  }

  /**
   * Toggles hidden course option.
   */
  toggleHideCourse(String courseName){
    Map courseInfoMap = (courseProgressMap[courseName])["info"];
    CourseOptions courseOptions = CourseOptions.fromInfoMap(courseInfoMap);
    courseOptions.toggleHide();
    courseOptions.writeToInfoMap(courseInfoMap);
    updateCourses();
  }

  /**
   *
   */
  _showCompletedWeekSnackBar(BuildContext context, int weekIndex){
    final snackBar = SnackBar(
      content: Text("Marked week " + weekIndex.toString() + " as complete"),
      action: SnackBarAction(
        label: "UNDO",
        onPressed: (){
          _restoreBackup(weekIndex);
        },
      ),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /**
   *
   */
  _showPendingWeekSnackBar(BuildContext context, int weekIndex){
    final snackBar = SnackBar(
      content: Text("Marked empty fields in week " + weekIndex.toString() + " as pending"),
      action: SnackBarAction(
        label: "UNDO",
        onPressed: (){
          _restoreBackup(weekIndex);
        },
      ),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /**
   *
   */
  _showClearedAllPendingInWeekSnackBar(BuildContext context, int weekIndex){
    final snackBar = SnackBar(
      content: Text("Cleared pending fields in week " + weekIndex.toString()),
      action: SnackBarAction(
        label: "UNDO",
        onPressed: (){
          _restoreBackup(weekIndex);
        },
      ),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /**
   *
   */
  _showClearedWeekSnackBar(BuildContext context, int weekIndex){
    final snackBar = SnackBar(
      content: Text("Cleared week " + weekIndex.toString()),
      action: SnackBarAction(
        label: "UNDO",
        onPressed: (){
          _restoreBackup(weekIndex);
        },
      ),
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /**
   * Returns cell status of the given course's fieldType at weekIndex
   */
  CellStatus _getCellStatus(String courseName, String classType, int weekIndex){
    int numOfWeeks = 13;
    List fieldList = courseProgressMap[courseName]['data'][classType];
    if(fieldList.contains(-weekIndex)){
      return CellStatus.Pending;
    } else if(fieldList.contains(weekIndex)){
      return CellStatus.Complete;
    } else if(fieldList.contains(weekIndex+numOfWeeks)){
      return CellStatus.Double;
    } else {
      return CellStatus.Empty;
    }
  }

  /**
   * Returns cell status of the given parameters as stored in the backupMap
   */
  CellStatus _getBackedUpCellStatus(String courseName, String classType, int weekIndex){
    return backupMap[weekIndex][courseName][classType];
  }

  /**
   * Converts non-empty CellStatus to the the appropriate index to be stored in the fieldlist
   */
  int _cellStatusToIndex(CellStatus cellStatus, int weekIndex){
    int numOfWeeks = 13;
    if(cellStatus == CellStatus.Pending){
      return -weekIndex;
    } else if(cellStatus == CellStatus.Complete){
      return weekIndex;
    } else if(cellStatus == CellStatus.Double){
      return weekIndex+numOfWeeks;
    } else {
      //Not supposed to get here
      return 0;
    }
  }

  /**
   * Clears cell located at the given parameters
   */
  _clearCell(int weekIndex, String courseName, String classType){
    int numOfWeeks = 13;
    List fieldList = courseProgressMap[courseName]['data'][classType];
    fieldList.remove(-weekIndex);
    fieldList.remove(weekIndex);
    fieldList.remove(weekIndex + numOfWeeks);
  }

  /**
   * Stores a backup of a given week, for all courses and class types (including hidden courses)
   */
  _storeBackup(int weekIndex){
    backupMap.clear();
    Map<String, Map<String, CellStatus>> weekMap = backupMap[weekIndex] = {};
    for(String courseName in courseOrder){
      Map courseMap = courseProgressMap[courseName];
      Map courseData = courseMap['data'];
      Map courseInfo = courseMap['info'];
      var courseOptions = CourseOptions.fromInfoMap(courseInfo);

      List<String> classTypes = [];
      int lectureCount = courseOptions.lectureCount;
      int tutorialCount = courseOptions.tutorialCount;
      int workShopCount = courseOptions.workShopCount;

      if(lectureCount>0){
        classTypes.add(Strings.lecture);
      }
      if(tutorialCount>0){
        classTypes.add(Strings.tutorial);
      }
      if(workShopCount>0){
        classTypes.add(Strings.workshop);
      }

      Map<String, CellStatus> courseWeekMap = weekMap[courseName] = {};
      for (String classType in classTypes){
        courseWeekMap[classType] = _getCellStatus(courseName, classType, weekIndex);
      }
    }
  }

  /**
   * Restores backed up week for all courses and class types (including hidden courses)
   */
  _restoreBackup(int weekIndex){
    Map<String, Map<String, CellStatus>> weekMap = backupMap[weekIndex];
    for (String courseName in courseOrder){
      Map courseMap = courseProgressMap[courseName];
      Map courseData = courseMap['data'];
      Map courseInfo = courseMap['info'];
      var courseOptions = CourseOptions.fromInfoMap(courseInfo);

      List<String> classTypes = [];
      int lectureCount = courseOptions.lectureCount;
      int tutorialCount = courseOptions.tutorialCount;
      int workShopCount = courseOptions.workShopCount;

      if(lectureCount>0){
        classTypes.add(Strings.lecture);
      }
      if(tutorialCount>0){
        classTypes.add(Strings.tutorial);
      }
      if(workShopCount>0){
        classTypes.add(Strings.workshop);
      }

      for (String classType in classTypes){
        _clearCell(weekIndex, courseName, classType);
        var cellStatus = _getBackedUpCellStatus(courseName, classType, weekIndex);
        if(cellStatus != CellStatus.Empty){
          List fieldList = courseProgressMap[courseName]['data'][classType];
          fieldList.add(_cellStatusToIndex(cellStatus, weekIndex));
        }
      }
    }
    updateCourses();
  }
}