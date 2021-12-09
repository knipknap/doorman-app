import 'package:flutter/material.dart';

class ClipPainter extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    var height = size.height;
    var width = size.width;
    var path = Path();

    path.lineTo(-1, size.height+1);
    path.lineTo(width, height);
    path.lineTo(width, 0);
    path.quadraticBezierTo(-width*.2, 0, width*.15, height*.3+10);
    path.quadraticBezierTo(width*.35, height*.45, width*.3, height*.6);
    path.quadraticBezierTo(width*.2, height, width, height);
    path.lineTo(-1, size.height+1);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}