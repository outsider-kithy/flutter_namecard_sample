import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:  Text('手動入力')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('手動入力'),
      ),
    );
  }
}