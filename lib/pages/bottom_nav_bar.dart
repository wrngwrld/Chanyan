import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/pages/boards/board_list.dart';
import 'package:flutter_chan/pages/bookmarks/bookmarks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key key}) : super(key: key);

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BoardList(),
    const Bookmarks(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return Scaffold(
      bottomNavigationBar: PlatformNavBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Boards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Bookmarks',
          ),
        ],
        currentIndex: _selectedIndex,
        itemChanged: _onItemTapped,
        material: (_, __) => MaterialNavBarData(
          showUnselectedLabels: false,
          unselectedItemColor: Colors.grey,
          selectedItemColor: AppColors.kGreen,
        ),
        cupertino: (_, __) => CupertinoTabBarData(
          backgroundColor: theme.getTheme() == ThemeData.dark()
              ? CupertinoColors.black
              : CupertinoColors.white,
          iconSize: 25,
        ),
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
    );
  }
}
