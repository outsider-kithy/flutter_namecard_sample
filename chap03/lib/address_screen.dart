import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {

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