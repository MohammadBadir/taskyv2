class CourseOptions{
  bool hasLecture;
  bool hasTutorial;
  //bool hasWorkshop;
  bool isSinglton;
  CourseOptions(this.isSinglton,[this.hasLecture = false,this.hasTutorial = false]);
}