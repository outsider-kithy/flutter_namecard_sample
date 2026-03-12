import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory applicationDirectory;

    if (Platform.isIOS) {
      // iOSは Application Support ディレクトリ
      applicationDirectory = await getApplicationSupportDirectory();
    } else if (Platform.isAndroid) {
      // Androidは Documents ディレクトリ
      applicationDirectory = await getApplicationDocumentsDirectory();
    } else {
      //その他のプラットフォーム
      applicationDirectory = await getApplicationSupportDirectory();
    }

    // ディレクトリパスを表示（デバッグ用）
    print('Application Directory: ${applicationDirectory.path}');

    // ディレクトリがなければ作成
    await Directory(applicationDirectory.path).create(recursive: true);

    // DBファイルのフルパス
    final String path = join(applicationDirectory.path, 'namepile.sqlite');
    print('Database path: $path');

    // データベースを開く（存在しなければ onCreate に従って作成）
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }


  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS namecards (
        primary_key INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        company TEXT,
        email TEXT,
        company_tel TEXT,
        mobile_tel TEXT,
        address TEXT,
        memo TEXT,
        created INTEGER
      )
    ''');

    // 初期データ挿入（ダミー5件）
    await db.execute('''
      INSERT INTO namecards (name, company, email, company_tel, mobile_tel, address, memo, created) VALUES
      ('山田太郎', '株式会社サンプル', 'taro.yamada@example.com', '0300000001', '09011112222', '東京都千代田区1-1-1', '営業担当', 1734500000),
      ('佐藤花子', '株式会社テック', 'hanako.sato@example.com', '0300000002', '08022223333', '東京都渋谷区2-2-2', 'Flutter開発', 1734600000),
      ('鈴木一郎', '株式会社マーケット', 'ichiro.suzuki@example.com', '0300000003', '07033334444', '東京都新宿区3-3-3', '新規事業', 1734700000),
      ('高橋久美子', '株式会社デザイン', 'kumiko.takahashi@example.com', '0300000004', '09044445555', '東京都豊島区4-4-4', 'UI担当', 1734800000),
      ('田中健', '株式会社システム', 'ken.tanaka@example.com', '0300000005', '08055556666', '東京都台東区5-5-5', '基幹システム', 1734900000)
    ''');
  }


// READ
  Future<List<Map<String, dynamic>>> fetchAllNamecards() async {
    final db = await database;
    return await db.query(
      'namecards'
    );
  }

// INSERT
  Future<void> insertNamecard(
      String name,
      String company,
      String email,
      String companyTel,
      String mobileTel,
      String address,
      String memo,
      int created) async {
    final db = await database;
    await db.insert(
      'namecards',
      {
        'name': name,
        'company': company,
        'email': email,
        'company_tel': companyTel,
        'mobile_tel': mobileTel,
        'address': address,
        'memo': memo,
        'created': created
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// DELETE
  Future<void> deleteNamecard(int pk) async {
    final db = await database;
    await db.delete(
      'namecards',
      where: 'primary_key = ?',
      whereArgs: [pk],
    );
  }

// UPDATE
  Future<void> updateNamecard(int pk, {
    String? name,
    String? company,
    String? email,
    String? companyTel,
    String? mobileTel,
    String? address,
    String? memo,
  }) async {
    final db = await database;
    await db.update(
      'namecards',
      {
        if (name != null) 'name': name,
        if (company != null) 'company': company,
        if (email != null) 'email': email,
        if (companyTel != null) 'company_tel': companyTel,
        if (mobileTel != null) 'mobile_tel': mobileTel,
        if (address != null) 'address': address,
        if (memo != null) 'memo': memo,
      },
      where: 'primary_key = ?',
      whereArgs: [pk],
    );
  }
}