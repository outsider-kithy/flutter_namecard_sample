import 'package:flutter/material.dart';

class AdressScreen extends StatefulWidget {
  @override
  _AdressScreenState createState() => _AdressScreenState();
}

class _AdressScreenState extends State<AdressScreen> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:  Text('名刺一覧')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('名刺一覧'),
      ),
    );
  }
}