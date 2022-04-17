import 'package:flutter/material.dart';

class CardWrapper extends StatelessWidget {
  final Widget content;
  final double cardHeight;
  final bool includeBorders;
  final Color mainColor;

  const CardWrapper(this.content, this.cardHeight, {this.includeBorders = false, this.mainColor = Colors.blueAccent, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BoxDecoration borders = null;

    if(includeBorders){
      borders = BoxDecoration(
          border: Border(
              bottom: BorderSide(color: mainColor, width: 5),
              top: BorderSide(color: mainColor, width: 5)
          )
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: cardHeight,
      child: Card(
        color: Colors.white,
        child: ClipPath(
          child: Container(
            child: content,
            decoration: borders
          ),
          clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3)
              )
          ),
        ),
      ),
    );
  }
}
