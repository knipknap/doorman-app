import 'package:flutter/material.dart';
import 'clip_painter.dart';

class BezierContainer extends StatelessWidget {
  const BezierContainer({Key ?key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipPainter(),
      child: Container(
        height: MediaQuery.of(context).size.height *.55,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [
                Color(0xfffbb448),
                Color(0xffe46b10),
              ]
            )
          ),
      ),
    );
  }
}