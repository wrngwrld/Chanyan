import 'package:flutter/material.dart';
import 'package:flutter_chan/constants.dart';
import 'package:flutter_chan/pages/board_list.dart';
import 'package:flutter_chan/pages/favorite_list.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  List<Widget> _pages = <Widget>[
    BoardList(),
    FavoriteList(),
  ];

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
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
        onTap: _onItemTapped,
        showUnselectedLabels: false,
        selectedItemColor: AppColors.kGreen,
        unselectedItemColor: AppColors.kBlack,
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
    );
  }
}
