class Subject{
  String label;
  int startTime;
  int endTime;
  bool isEmpty;
  Subject(this.label, this.startTime, this.endTime){
    isEmpty = false;
  }
  Subject.whiteSpace(this.startTime, this.endTime){
    isEmpty = true;
  }
  int duration(){
    return endTime-startTime;
  }
}

//Adds whitespace to Subject list
List<Subject> processSubjectList(List<Subject> inputList){
  int maxSize = 21;
  List<Subject> outputList = [];
  inputList.sort((Subject a, Subject b) => a.startTime.compareTo(b.startTime));

  //If list is empty, then output is a list containing a single whitespace
  if(inputList.isEmpty){
    outputList.add(Subject.whiteSpace(0, maxSize));
    return outputList;
  }

  //If first subject isn't at the beginning of the day, add whitespace of fitting size
  if(inputList.first.startTime > 0){
    outputList.add(Subject.whiteSpace(0, inputList.first.startTime));
  }

  //Add subjects and whitespaces
  for(int i=0; i<inputList.length; ++i){
    Subject curr = inputList[i];
    Subject next = i<inputList.length-1 ? inputList[i+1] : null;
    outputList.add(curr);
    if(next != null && next.startTime>curr.endTime){
      outputList.add(Subject.whiteSpace(curr.endTime, next.startTime));
    }
    if(next == null && maxSize>curr.endTime){
      outputList.add(Subject.whiteSpace(curr.endTime, maxSize));
    }
  }

  return outputList;
}