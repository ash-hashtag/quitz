import 'package:flutter/material.dart';

class Themes {
  static final light = ThemeData(
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      subtitle1: TextStyle(color: Colors.black),
      subtitle2: TextStyle(color: Colors.black),
      bodyText1: TextStyle(color: Colors.black),
      bodyText2: TextStyle(color: Colors.black),
    ),
  );
  static final dark = ThemeData(
      scaffoldBackgroundColor: Colors.black,
      backgroundColor: Colors.black,
      textTheme: const TextTheme(
        subtitle1: TextStyle(color: Colors.white),
        subtitle2: TextStyle(color: Colors.white),
        bodyText1: TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purple)
      )));
}
