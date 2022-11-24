import 'package:flutter/material.dart';
import 'package:last_mile_v2/drivers/tabpages/driverhometabpage.dart';
import 'package:last_mile_v2/drivers/tabpages/earningstabpage.dart';
import 'package:last_mile_v2/drivers/tabpages/profiletabpage.dart';
import 'package:last_mile_v2/drivers/tabpages/ratingtabpage.dart';
import 'package:last_mile_v2/localization/language_constants.dart';

class DriverMainScreen extends StatefulWidget {
  static const String idScreen = "drivermainscreen";
  @override
  _DriverMainScreenState createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  int selectedIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController.index = selectedIndex;
    });
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          DriverHomeTabPage(),
          DriverEarningsTabPage(),
          DriverRatingTabPage(),
          DriverProfileTabPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: getTranslated(context, "Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: getTranslated(context, "Earnings"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: getTranslated(context, "Rating"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: getTranslated(context, "Account"),
          ),
        ],
        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12.0),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
