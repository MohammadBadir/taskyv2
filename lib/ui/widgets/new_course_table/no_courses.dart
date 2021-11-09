import 'package:flutter/material.dart';

class NoCoursesWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("No courses found.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Click on the Edit button to add some!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24
              ),
            ),
          )
        ],
      ),
    );
  }

}