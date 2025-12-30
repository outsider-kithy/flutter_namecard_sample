import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detected_namecard.dart';

class OcrScreen extends StatefulWidget {
  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {

  final ImagePicker _picker = ImagePicker();
  File? _image;

  //検出した文字列を格納する配列
  List<String> _detectedTexts = [];
  // 日本語用のTextRecognizer
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
  //APIからのレスポンスを格納
  late List<dynamic> results = [];

  bool _loading = false;
  String _progressMessage = '';

  bool _isDetectInfoRunning = false;
  bool _isDetectInfoCancelled = false;

  //画像を選択
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    setState(() {
      _image = File(imageFile.path);
    });

    await _processImage(imageFile);
  }

  //カメラor写真を選択
  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('ギャラリーから選択'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('カメラで撮影'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// 縦書き判定 → OCR
  Future<void> _processImage(File file) async {
    // 画像を読み込み
    img.Image? original = img.decodeImage(await file.readAsBytes());
    if (original == null) return;

    // 長辺を1200pxに縮小（メモリ軽量化）
    if (original.width > original.height && original.width > 1200) {
      original = img.copyResize(original, width: 1200);
    } else if (original.height > 1200) {
      original = img.copyResize(original, height: 1200);
    }

    // InputImage作成
    final inputImage = InputImage.fromFile(file); // XFileをFileに変換している場合

    // OCR実行（1回だけ）
    final recognizedText = await _textRecognizer.processImage(inputImage);

    // 縦書き判定（面積ベース）
    double verticalArea = 0;
    double horizontalArea = 0;

    for (final block in recognizedText.blocks) {
      final rect = block.boundingBox;
      final area = rect.width * rect.height;
      if (rect.height > rect.width) {
        verticalArea += area;
      } else {
        horizontalArea += area;
      }
    }

    final isVertical = verticalArea > horizontalArea;

    // 縦書きの場合は右→左、上→下でテキスト結合
    String resultText;
    if (isVertical) {
      final blocks = recognizedText.blocks
        ..sort((a, b) => b.boundingBox.left.compareTo(a.boundingBox.left));
      resultText = blocks.map((block) {
        final lines = block.lines
          ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));
        return lines.map((line) => line.text).join('\n');
      }).join('\n');
      _detectedTexts.add(resultText);
    } else {
      _detectedTexts.add(recognizedText.text);
      print(_detectedTexts);
    }
  }

  //_detectedTextsを外部APIに送る
  Future<Map<String, dynamic>> detectInfo(List<String> texts) async {
    final url = Uri.parse(
        'https://namepile-api-67202345724.asia-northeast1.run.app/detectInfo/');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(texts),
    );

    if (response.statusCode == 200) {
      print(response.body);
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded;
    } else {
      throw Exception(
          'detectInfo APIへのPOSTに失敗しました: ${response.statusCode}');
    }
  }

  //情報検出APIに接続
  void _sendTextsToDetectInfoApi() async {
    setState(() {
      _isDetectInfoRunning = true;
      _isDetectInfoCancelled = false;
      _loading = true;
      _progressMessage = '情報を検出中...';
    });

    if (_isDetectInfoCancelled) return;

    try {
      Map<String, dynamic> results = await detectInfo(_detectedTexts);

      setState(() {
        _isDetectInfoRunning = false;
        _loading = false;
        _progressMessage = '';
      });

      //個別ページに遷移
      if (context.mounted || results.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetectednamecardScreen(detectInfo: results),
          ),
        );
        setState(() {
          _image = null;
          _detectedTexts = [];
          results = {};
        });
      }

    } catch (e) {
      print('_sendTextsToDetectInfoApiエラー: $e');
    }
  }

  //_sendTextsToDetectInfoApiをキャンセル
  void _cancelDetectInfo() {
    setState(() {
      _isDetectInfoCancelled = true;
      _isDetectInfoRunning = false;
      _loading = false;
      _progressMessage = '情報検出がキャンセルされました';
    });
  }


  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context){
    return Stack(
        children: [
          Scaffold(
            appBar: AppBar(title: Text('写真選択'), centerTitle: true),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  if (_image == null)
                    Column(
                      children: [
                        SizedBox(height: 16),
                        Center(child: Text('画像が選択されていません')),
                        SizedBox(height: 16),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Center(child: Text('選択した画像')),
                        SizedBox(height: 16),
                        Image.file(
                          _image!,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded || frame != null) {
                              return Column(
                                children: [
                                  child,
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _sendTextsToDetectInfoApi,
                                    child: Text('情報を検出'),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              );
                            } else {
                              return SizedBox(
                                height: 200,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                        ),
                      ],
                    )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showPickerOptions(context),
              child: Icon(Icons.add_a_photo),
            ),
          ),

          // ローディング中のオーバーレイ（全画面）
          if (_loading)
            ModalBarrier(
              dismissible: false,
            ),
          if (_loading)
            Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                        _progressMessage,
                        style: TextStyle(
                          color: Colors.white,
                        )
                    ),
                    SizedBox(height: 16),

                    if (_isDetectInfoRunning)
                      ElevatedButton(
                        onPressed: _cancelDetectInfo,
                        child: Text('情報検出をキャンセル'),
                      ),
                    SizedBox(height: 16),
                  ]
              ),
            ),
        ]
    );
  }
}