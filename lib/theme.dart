import 'package:flutter/material.dart';

OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(2),
  borderSide: BorderSide(style: BorderStyle.none, width: 0),
  gapPadding: 10,
);

InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    labelStyle: TextStyle(
      color: Colors.grey.shade700,
      fontSize: 18,
    ),
    //floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    filled: true,
    fillColor: Colors.white,
    focusColor: Colors.white,
    hoverColor: Colors.white,
    border: outlineInputBorder,
    focusedBorder: outlineInputBorder,
);

ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    background: Colors.indigo,
    onBackground: Colors.black,

    primary: Colors.indigo,
    primaryVariant: Colors.indigoAccent,
    onPrimary: Colors.white,

    secondary: Colors.orange,
    secondaryVariant: Colors.orange.shade900,
    onSecondary: Colors.black,

    surface: Colors.indigo.shade800,
    onSurface: Colors.pink,

    error: Colors.red,
    onError: Colors.white,
);

ThemeData themeData = ThemeData(
  colorScheme: colorScheme,
  backgroundColor: Colors.indigoAccent,
  scaffoldBackgroundColor: Colors.indigoAccent,
  primarySwatch: Colors.indigo,
  hintColor: Colors.black,
  inputDecorationTheme: inputDecorationTheme,
);