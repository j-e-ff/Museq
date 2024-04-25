import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/Themes/light_Mode.dart';
import 'package:my_first_flutter_project/Themes/dark_Mode.dart';


class ThemeProvider extends ChangeNotifier{
  // light mode
  ThemeData _themeData = lightMode;

  // getting theme
  ThemeData get themeData => _themeData;

  // is dark
  bool get isDarkMode => _themeData == darkMode;

  //setting theme
  set themeData(ThemeData themeData){
    _themeData = themeData;
    //update UI
    notifyListeners();
  }

  //toggle theme
  void toggleTheme(){
    if(_themeData == lightMode){
      themeData = darkMode;
    }
    else{
      themeData = lightMode;
    }
  }
}
