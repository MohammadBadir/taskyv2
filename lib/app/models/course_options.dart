class CourseOptions{
  bool isSingleton = false;
  int lectureCount = 0;
  int tutorialCount = 0;
  int workShopCount = 0;
  bool hasLecture = false;
  bool hasDoubleLecture = false;
  bool hasTutorial = false;
  bool hasWorkshop = false;

  CourseOptions(this.isSingleton, [
        this.hasLecture = false,
        this.hasTutorial = false,
        this.hasWorkshop = false
      ]);

  CourseOptions.singleton() : isSingleton = true;

  CourseOptions.general();
}