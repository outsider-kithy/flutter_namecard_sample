import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';
import 'editable_field.dart';

class EditNamecardScreen extends StatefulWidget {
  final Database db;
  final int pk;
  final String name;
  final String company;
  final String email;
  final String companyTel;
  final String mobileTel;
  final String address;
  final String memo;
  final int created;

  const EditNamecardScreen({
    Key? key,
    required this.db,
    required this.pk,
    required this.name,
    required this.company,
    required this.email,
    required this.companyTel,
    required this.mobileTel,
    required this.address,
    required this.memo,
    required this.created,

  }) : super(key: key);

  @override
  _EditNamecardScreenState createState() => _EditNamecardScreenState();
}

class _EditNamecardScreenState extends State<EditNamecardScreen> {

   late Database _db;

  // 各フィールドのコントローラ
  late TextEditingController nameController;
  late TextEditingController companyController;
  late TextEditingController emailController;
  late TextEditingController companyTelController;
  late TextEditingController mobileTelController;
  late TextEditingController addressController;
  late TextEditingController memoController;

    @override
    void initState() {
      super.initState();
      _initAndLoad();
      //ページ描画時にコントローラを初期化
      nameController = TextEditingController(text: widget.name);
      companyController = TextEditingController(text: widget.company);
      emailController = TextEditingController(text: widget.email);
      companyTelController = TextEditingController(text: widget.companyTel);
      mobileTelController = TextEditingController(text: widget.mobileTel);
      addressController = TextEditingController(text: widget.address);
      memoController = TextEditingController(text: widget.memo);
    }

    Future<void> _initAndLoad() async {
        _db = await DatabaseHelper().database;
    }

    final _formKey = GlobalKey<FormState>();

    void dispose() {
      nameController.dispose();
      companyController.dispose();
      emailController.dispose();
      companyTelController.dispose();
      mobileTelController.dispose();
      addressController.dispose();
      memoController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('名刺情報を編集')),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // フォーム全体を管理
          child: ListView(
            children: [
              EditableField(
                label: "お名前",
                controller: nameController,
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
                      nameController.text = value.toString();
                    });
                  }
              ),
              EditableField(
                label: "会社名",
                controller: companyController,
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return null; //未入力であればスルー
                  } else if(value.length > 30){
                    return "会社名は30文字以下で入力してください";
                  }
                  return null;
                },
                  onSaved: (value) {
                    setState(() {
                      companyController.text = value ?? "";
                    });
                  }
              ),
              EditableField(
                label: "メールアドレス",
                controller: emailController,
                validator: (value) {
                  final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                  if (value == null || value.isEmpty ){
                    return null; //未入力であればスルー
                  } else if (!regex.hasMatch(value)) {
                    return "メールアドレスの形式が正しくありません";
                  } else if(value.length > 100) {
                    return "メールアドレスは100文字以下で入力してください";
                  }
                  return null;
                },
                  onSaved: (value) {
                    setState(() {
                      emailController.text = value ?? "";
                    });
                  }
              ),
              EditableField(
                label: "会社の電話番号",
                controller: companyTelController,
                validator: (value) {
                  final regex = RegExp(r'(0\d{1,4}-\d{1,4}-\d{4}-|0\d{9,10})');
                  if (value == null || value.isEmpty){
                    return null; //未入力であればスルー
                  } else if (!regex.hasMatch(value)) {
                    return "会社の電話番号は半角数字で入力してください";
                  }
                  return null;
                },
                  onSaved: (value) {
                    setState(() {
                      companyTelController.text = value ?? "";
                    });
                  }
              ),
              EditableField(
                label: "携帯電話",
                controller: mobileTelController,
                validator: (value) {
                  final regex = RegExp(r'(0\d{1,4}-\d{1,4}-\d{4}-|0\d{9,10})');
                  if (value == null || value.isEmpty){
                    return null; //未入力であればスルー
                  } else if (!regex.hasMatch(value)) {
                    return "携帯電話番号は半角数字で入力してください";
                  }
                  return null;
                },
                  onSaved: (value) {
                    setState(() {
                      mobileTelController.text = value ?? "";
                    });
                  }
              ),
              EditableField(
                label: "住所",
                controller: addressController,
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return null; //未入力であればスルー
                  } else if (value.length > 150) {
                    return "住所は150文字以下で入力してください";
                  }
                  return null;
                },
                  onSaved: (value) {
                    setState(() {
                      addressController.text = value ?? "";
                    });
                  }
              ),
              EditableField(
                label: "メモ（200字以内）",
                controller: memoController,
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return null; //未入力であればスルー
                  } else if (value.length > 200) {
                    return "メモは200文字以下で入力してください";
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    memoController.text = value ?? "";
                  });
                }
              ),

              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save(); // onSavedを発火させる

                await DatabaseHelper().updateNamecard(
                  widget.pk, // 更新対象の主キー
                  name: nameController.text,
                  company: companyController.text,
                  email: emailController.text,
                  companyTel: companyTelController.text,
                  mobileTel: mobileTelController.text,
                  address: addressController.text,

                  memo: memoController.text,
                );
                  Navigator.of(context).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.name}さんのデータを更新しました')),
                  );
                }
                },
                child: Text('更新'),
              ),

              SizedBox(height: 32),
            ],
          )
        ),
      )
      );
    }
  }
