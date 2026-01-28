import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';
import 'editable_field.dart';

class DetectednamecardScreen extends StatefulWidget {

  final Map<String, dynamic> detectInfo;

  DetectednamecardScreen({
    required this.detectInfo
  });

  @override
  _DetectednamecardScreenState createState() => _DetectednamecardScreenState();
}

class _DetectednamecardScreenState extends State<DetectednamecardScreen> {
  late Database _db;

  Future<List<Map<String, dynamic>>>? _namecardListFuture;

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

    nameController = TextEditingController(text: widget.detectInfo['name'] ?? "");
    companyController = TextEditingController(text: widget.detectInfo['company_name'] ?? "");
    emailController = TextEditingController(text: widget.detectInfo['email'] ?? "");
    companyTelController = TextEditingController(text: widget.detectInfo['company_tel'] ?? "");
    mobileTelController = TextEditingController(text: widget.detectInfo['mobile_tel'] ?? "");
    addressController = TextEditingController(text: widget.detectInfo['address']);
    memoController = TextEditingController(text: "");
  }

  Future<void> _initAndLoad() async {
    _db = await DatabaseHelper().database;
    setState(() {
      _namecardListFuture = DatabaseHelper().fetchAllNamecards();
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('検出結果'), centerTitle: true),

      body: widget.detectInfo.isEmpty
          ? Center(child: Text('名刺が見つかりませんでした'))
          :   Padding(padding: const EdgeInsets.all(16.0),
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

                        await DatabaseHelper().insertNamecard(
                            nameController.text.isNotEmpty
                                ? nameController.text
                                : "",
                            companyController.text.isNotEmpty
                                ? companyController.text
                                : "",
                            emailController.text.isNotEmpty ? emailController
                                .text : "",
                            companyTelController.text.isNotEmpty
                                ? companyTelController.text
                                : "",
                            mobileTelController.text.isNotEmpty
                                ? mobileTelController.text
                                : "",
                            addressController.text.isNotEmpty
                                ? addressController.text
                                : "",
                            memoController.text.isNotEmpty
                                ? memoController.text
                                : "",
                            convertToUnixTimestamp(DateTime.now().toString())
                        );

                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${nameController
                              .text}さんのデータを追加しました')),
                        );
                      }
                    },
                    child: Text('追加'),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              )
            )
          );
      }
}