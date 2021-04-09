import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/app/drawer/my_drawer.dart';
import 'package:tasky/app/services/user_db.dart';

class CourseGridWidget extends StatelessWidget {
  Widget gridMaker(List courseOrder, Map courseProgressMap){
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("dummy")),),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Text(Provider.of<UserDB>(context).courseOrder.toString()),
          ElevatedButton(
              onPressed: () {
                Provider.of<UserDB>(context,listen: false).addWord("AddedWord");
              },
              child: Text("AddWord")
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){},),
    );
  }
}