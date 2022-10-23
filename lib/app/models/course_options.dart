class CourseOptions{
  bool isSingleton = false;
  int lectureCount = 0;
  int tutorialCount = 0;
  int workShopCount = 0;
  bool isHidden = false;

  CourseOptions();
  CourseOptions.singleton() : isSingleton = true;
  CourseOptions.fromInfoMap(Map courseInfo){
    this.lectureCount = courseInfo['lectureCount'];
    this.tutorialCount = courseInfo['tutorialCount'];
    this.workShopCount = courseInfo['workshopCount'];

    //Backwards compatibility - Added in v0.5dev
    this.isHidden = courseInfo.containsKey('isHidden') ? courseInfo['isHidden'] : false;

    if (this.lectureCount + this.tutorialCount +
        this.workShopCount == 0) {
      this.isSingleton = true;
    }
  }

  /**
   * Toggles hidden option.
   */
  toggleHide(){
    this.isHidden = !this.isHidden;
  }

  writeToInfoMap(Map courseInfo){
    courseInfo['lectureCount'] = this.lectureCount;
    courseInfo['tutorialCount'] = this.tutorialCount;
    courseInfo['workshopCount'] = this.workShopCount;
    courseInfo['isHidden'] = this.isHidden;
  }

}