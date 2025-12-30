import 'package:flutter/material.dart';
import 'AdressScreen.dart';
import 'OcrScreen.dart';
import 'AddScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Tab Layout Demo',
      home: MainTabScreen(),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AdressScreen(),
    OcrScreen(),
    AddScreen(),
  ];

  void _onTabTapped(int index){
    setState(() {
      _currentIndex  = index;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const[
            BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: '名刺一覧'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.camera),
                label: '画像読取'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.edit),
                label: '手動入力'
            ),
          ]),
    );
  }
}