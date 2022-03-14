import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasky/ui/widgets/new_course_table/widgets/card_wrapper.dart';
import '../../../../app/services/user_db.dart';

class WeekBar extends StatelessWidget {
  const WeekBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color mainColor = Provider.of<UserDB>(context).mainColor;

    var raw = Container(
      color: Colors.green,
      child: Row(
        children: List.generate(
            31,
                (index) => index % 2 == 0
                ? Container(
              width: index==2 ? 0 : 5,
              color: mainColor,
            )
                : Expanded(
              child: Container(
                child: Center(
                    child: index == 3
                        ? null
                        : Text(
                      index == 1
                          ? "Course"
                          : (index ~/ 2 - 1).toString(),
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    )),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white),
              ),
              flex: index == 1 ? 9 : (index == 3 ? 0 : 2),
            )),
      ),
    );

    return CardWrapper(raw, 50, includeBorders: true, mainColor: mainColor);
  }
}
