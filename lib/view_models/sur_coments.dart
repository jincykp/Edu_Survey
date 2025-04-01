import 'package:flutter/material.dart';

class SurveyProvider extends ChangeNotifier {
  String areaName = '';
  int totalSchools = 0;
  int selectedIndex = 0;
  List<String> sidebarItems = ['General Data'];

  void setAreaName(String name) {
    areaName = name;
    notifyListeners();
  }

  void updateTotalSchools(int count) {
    if (count >= 0 && count <= 5) {
      totalSchools = count;

      // Reset sidebar items and recreate them
      sidebarItems = ['General Data'];
      for (int i = 1; i <= count; i++) {
        sidebarItems.add('School-$i');
      }

      notifyListeners();
    }
  }

  void selectItem(int index) {
    if (index >= 0 && index < sidebarItems.length) {
      selectedIndex = index;
      notifyListeners();
    }
  }
}
