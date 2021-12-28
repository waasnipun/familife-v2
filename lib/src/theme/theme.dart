import 'package:familife/src/theme/colors.dart';
import 'package:flutter/material.dart';


class AppTheme {
  const AppTheme();
  static ThemeData familifeTheme = ThemeData(
    appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
        ),
    primaryColor: FamilifeColors.mainBlue,
    primaryColorDark: FamilifeColors.darkgrey,
    primaryColorLight: FamilifeColors.lightGrey,
    accentColor: FamilifeColors.mainBlue,
    dividerColor: FamilifeColors.darkgrey,
    fontFamily: 'Gilroy',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static TextStyle logoTitle = const TextStyle(
      color: Colors.black,
      fontSize: 46,
      fontWeight: FontWeight.bold,
      fontFamily: 'Gilroy');
  static TextStyle title = const TextStyle(
      color: FamilifeColors.mainBlue,
      fontSize: 18,
      fontWeight: FontWeight.normal,
      fontFamily: 'Gilroy',
      letterSpacing: 0.0);
  static TextStyle titleblack = const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontFamily: 'Gilroy',
      letterSpacing: 0.0);
  static TextStyle subTitile = const TextStyle(
      color: FamilifeColors.mainBlue,
      fontSize: 15,
      fontWeight: FontWeight.normal,
      fontFamily: 'Gilroy');
  static TextStyle appBarTitle = const TextStyle(
      color: FamilifeColors.mainBlue,
      fontSize: 15,
      fontWeight: FontWeight.bold,
      fontFamily: 'Gilroy');
  static TextStyle pinCode = const TextStyle(
      color: Colors.black,
      fontSize: 25,
      fontWeight: FontWeight.normal,
      fontFamily: 'Gilroy');
  static TextStyle textField =
      const TextStyle(color: Colors.grey, fontSize: 16, fontFamily: 'Gilroy');
  static TextStyle textFieldLabel =
      const TextStyle(color: FamilifeColors.lightGrey, fontSize: 15, fontFamily: 'Gilroy');
  static LinearGradient gradient = LinearGradient(
      colors: [
        const Color(0xFF0072FF),
        const Color(0xFF00B6FF),
      ],
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(1.0, 0.0),
      stops: [0.0, 1.0],
      tileMode: TileMode.clamp);
}
