import 'package:flutter/material.dart';

class OcrScreen extends StatefulWidget {
  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:  Text('画像読取')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('画像読取'),
      ),
    );
  }
}