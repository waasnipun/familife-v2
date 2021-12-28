import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget customText({text, color, weight, double? size, align}) {
  return Text(
    text,
    textAlign: align,
    maxLines: 3,
    style: TextStyle(
        color: color, fontWeight: weight, fontSize: size, fontFamily: "Gilroy"),
  );
}

Widget customContainer({height, width, color, image, radius}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
    ),
    child: SvgPicture.asset(
      image,
    ),
  );
}

Route pageRoute(page) {
  return CupertinoPageRoute(
      builder: (BuildContext context) {
        return page;
      },
    );
}

Route pageRouteNormal(page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}
Widget loadingScreen(){
  return Center(child: CupertinoActivityIndicator(radius: 15));
}

