import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'adress_screen.dart';
import 'ocr_screen.dart';
import 'add_screen.dart';
import 'database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初回起動時にDB作成
  await DatabaseHelper().database;
  //リモートAPIにpingを送る
  await confirmPing();
  runApp(MyApp());
}

//リモートAPIにpingを送る
Future confirmPing() async {
  final url = Uri.parse(
      'https://namepile.site/ping/');
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    print(response.body);
  } else {
    throw Exception(
        'リモートAPI起動確認: ${response.statusCode}');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Tab Layout Demo',
      home: MainTabScreen(),
      theme: ThemeData(
        fontFamily: 'NotoSansJP',
      ),
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