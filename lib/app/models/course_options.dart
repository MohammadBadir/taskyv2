class CourseOptions{
  bool isSingleton = false;
  int lectureCount = 0;
  int tutorialCount = 0;
  int workShopCount = 0;

  CourseOptions();
  CourseOptions.singleton() : isSingleton = true;
}