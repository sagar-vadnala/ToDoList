import 'package:flutter/material.dart';

const Color blueish = Color(0xFF4e5ae8);
const Color yellow = Color(0xFFFF8746);
const Color pink = Color(0xFFff4667);
const Color white = Colors.white;
const Color primaryColor = blueish;
const Color darkgrey = Color(0xFF121212);
Color darkHeader = Color(0xFF424242);


class Themes {

  static final light = ThemeData(
    primaryColor: primaryColor,
    brightness: Brightness.light
  );

  static final dark = ThemeData(
    primaryColor: darkgrey,
    brightness: Brightness.dark
  );
}