import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';
import 'package:intl/intl.dart';
import 'dart:ffi';

class AddScreen extends StatefulWidget {
  final Database? db;
  String name = '';
  String company = '';
  String email = '';
  String companyTel = '';
  String mobileTel = '';
  String address = '';
  String memo = '';
  String created = '';

  AddScreen({
    this.db,
  });

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {

  late Database _db;

  // 各フィールドのコントローラ
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyTelController = TextEditingController();
  final _mobileTelController = TextEditingController();
  final _addressController = TextEditingController();
  final _memoController = TextEditingController();

   @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    _db = await DatabaseHelper().database;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _companyTelController.dispose();
    _mobileTelController.dispose();
    _addressController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  // 電話番号から-を削除
  String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  //yyyy-MM-dd形式の文字列をUnixタイムスタンプ型に変換
  int convertToUnixTimestamp(String dateString) {
    // 区切り文字で分割
    final parts = dateString.split('-');

    // 年、月、日を初期化
    String year = parts[0];
    String month = parts.length > 1 ? parts[1].padLeft(2, '0') : '01';
    String day = parts.length > 2 ? parts[2].padLeft(2, '0') : '01';

    // 補完した文字列を作成
    final completedDateStr = '$year-$month-$day';

    // パースしてUTCとして扱う
    final date = DateTime.parse(completedDateStr).toUtc();

    // Unixタイムスタンプ（秒単位）に変換
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:  Text('手動入力')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
        key: _formKey, // フォーム全体を管理
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "お名前（必須）"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "お名前は必須です";
                } else if(value.length > 30){
                  return "お名前は30文字以下で入力してください";
                }
                return null;
              },
              onSaved: (value) {
                setState(() {
                  widget.name = value.toString();
                });
              }
            ),
            TextFormField(
                controller: _companyController,
                decoration: InputDecoration(labelText: "会社名"),
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return null; //未入力であればスルー
                  } else if(value.length > 30){
                    return "会社名は30文字以下で入力してください";
                  }
                },
                onSaved: (value) {
                  setState(() {
                    widget.company = value.toString();
                  });
                }
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "メールアドレス"),
              validator: (value) {
                final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                if (value == null || value.isEmpty ){
                  return null; //未入力であればスルー
                } else if (!regex.hasMatch(value)) {
                   return "メールアドレスの形式が正しくありません";
                } else if(value.length > 100) {
                   return "メールアドレスは100文字以下で入力してください";
                }
              },
              onSaved: (value) {
                setState(() {
                  widget.email = value.toString();
                });
              }
            ),
            TextFormField(
                controller: _companyTelController,
                decoration: InputDecoration(labelText: "会社の電話番号"),
                validator: (value) {
                  final regex = RegExp(r'(0\d{1,4}-\d{1,4}-\d{4}-|0\d{9,10})');
                  if (value == null || value.isEmpty){
                    return null; //未入力であればスルー
                  } else if (!regex.hasMatch(value)) {
                    return "会社の電話番号は半角数字で入力してください";
                  }
                },
                onSaved: (value) {
                  setState(() {
                    widget.companyTel = normalizePhone(value.toString());
                  });
                }
            ),

            TextFormField(
                controller: _mobileTelController,
                decoration: InputDecoration(labelText: "携帯の電話番号"),
                validator: (value) {
                  final regex = RegExp(r'(0\d{1,4}-\d{1,4}-\d{4}-|0\d{9,10})');
                  if (value == null || value.isEmpty){
                    return null; //未入力であればスルー
                  } else if (!regex.hasMatch(value)) {
                    return "携帯電話番号は半角数字で入力してください";
                  }
                },
                onSaved: (value) {
                  setState(() {
                    widget.mobileTel = normalizePhone(value.toString());
                  });
                }
            ),
            TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "住所"),
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return null; //未入力であればスルー
                  } else if (value.length > 150) {
                    return "住所は150文字以下で入力してください";
                  }
                },
                onSaved: (value) {
                  setState(() {
                    widget.address = value.toString();
                  });
                }
            ),
            TextFormField(
                controller: _memoController,
                decoration: InputDecoration(labelText: "メモ（200字以内）"),
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return null; //未入力であればスルー
                  } else if (value.length > 200) {
                    return "メモは200文字以下で入力してください";
                  }
                },
                onSaved: (value) {
                  setState(() {
                    widget.memo = value.toString();
                  });
                }
            ),
          ]
        )
      ),
      ),

       floatingActionButton: FloatingActionButton(
            onPressed: () async{
            // 送信時にバリデーション
            if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save(); // onSavedを発火させる
                await DatabaseHelper().insertNamecard(
                  widget.name,
                  widget.company,
                  widget.email,
                  widget.companyTel,
                  widget.mobileTel,
                  widget.address,
                  widget.memo,
                  convertToUnixTimestamp(
                      DateFormat('yyyy-MM-dd').format(DateTime.now())),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('「${widget.name}」さんを登録しました')),
                  );

                  //TextFieldをリセット
                  _nameController.clear();
                  _companyController.clear();
                  _emailController.clear();
                  _companyTelController.clear();
                  _mobileTelController.clear();
                  _addressController.clear();
                  _memoController.clear();

                  setState(() {
                    widget.name = "";
                    widget.company = "";
                    widget.email = "";
                    widget.companyTel = "";
                    widget.mobileTel = "";
                    widget.address = "";
                    widget.memo = "";
                  });
                }
              },
            child: Icon(Icons.add),
          )
    );
  }
}