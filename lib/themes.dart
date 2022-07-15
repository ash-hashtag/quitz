import 'package:flutter/material.dart';

class Themes {
  static final light = ThemeData(
    primaryColor: Colors.white,
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    secondaryHeaderColor: Colors.black,
    textTheme: const TextTheme(
      subtitle1: TextStyle(color: Colors.black),
      subtitle2: TextStyle(color: Colors.black),
      bodyText1: TextStyle(color: Colors.black),
      bodyText2: TextStyle(color: Colors.black),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purple),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
    ),
    cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.purple,
        surfaceTintColor: Colors.purple),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.purple, foregroundColor: Colors.white),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: null,
        textStyle: MaterialStateProperty.all(
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) => states.contains(MaterialState.disabled)
              ? Colors.grey
              : Colors.black,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: Offset(5.0, 5.0),
            blurRadius: 8.0,
            color: Colors.purple,
          ),
        ],
      ),
    ),
    listTileTheme: ListTileThemeData(
      selectedTileColor: Colors.purple,
      selectedColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.purple),
  );

  static final dark = ThemeData(
    secondaryHeaderColor: Colors.white,
    primaryColor: Colors.black,
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
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purple),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
    ),
    cardTheme: const CardTheme(
        color: Colors.black,
        elevation: 10,
        shadowColor: Colors.purple,
        surfaceTintColor: Colors.purple),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.purple, foregroundColor: Colors.black),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all<double>(10),
        backgroundColor: null,
        textStyle: MaterialStateProperty.all(
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) => states.contains(MaterialState.disabled)
              ? Colors.grey
              : Colors.white,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: Offset(5.0, 5.0),
            blurRadius: 8.0,
            color: Colors.purple,
          ),
        ],
      ),
    ),
    listTileTheme: ListTileThemeData(
        selectedTileColor: Colors.black,
        selectedColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        iconColor: Colors.white),
    popupMenuTheme:
        const PopupMenuThemeData(textStyle: TextStyle(color: Colors.black)),
    iconTheme: const IconThemeData(color: Colors.white),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.purple),
  );
}
