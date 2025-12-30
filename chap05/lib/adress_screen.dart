import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';
import 'edit_namecard.dart';

class AdressScreen extends StatefulWidget {
  @override
  _AdressScreenState createState() => _AdressScreenState();
}

class _AdressScreenState extends State<AdressScreen> {

  late Database _db;
  Future<List<Map<String, dynamic>>>? _namecardListFuture;

   @override
    void initState() {
      super.initState();
      _initAndLoad();
    }

  Future<void> _initAndLoad() async {
    _db = await DatabaseHelper().database;
    setState(() {
      _namecardListFuture =  DatabaseHelper().fetchAllNamecards();
    });
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:  Text('名刺一覧')),
      body: 
      FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper().fetchAllNamecards(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("エラー: ${snapshot.error}"));
            }
            final namecards = snapshot.data ?? [];
            return ListView.builder(
              itemCount: namecards.length,
              itemBuilder: (context, index) {
                final namecard = namecards[index];

                //スワイプして削除
                return Dismissible(
                  key: Key(namecard['primary_key'].toString()),
                  direction: DismissDirection.endToStart, // 右から左にスワイプ
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
              onDismissed: (direction) async {
                await DatabaseHelper().deleteNamecard(namecard['primary_key']);
                setState(() {
                  _namecardListFuture = DatabaseHelper().fetchAllNamecards();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('「${namecard['name']}」さんを削除しました')),
                );
              },

                child: Card(
                  child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(namecard['name']),
                      subtitle: Text(namecard['company']),
                      trailing: Icon(Icons.arrow_forward),

                      //タップして編集画面に遷移
                      onTap: () async {
                        final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          EditNamecardScreen(
                            db: _db,
                            pk: namecard['primary_key'],
                            name: namecard['name'],
                            company: namecard['company'] ?? '',
                            email: namecard['email'] ?? '',
                            companyTel: namecard['company_tel'] ?? '',
                            mobileTel: namecard['mobile_tel'] ?? '',
                            address: namecard['address'] ?? '',
                            memo: namecard['memo'] ?? '',
                            created: namecard['created'] ?? '',
                          ),
                        ),
                    );

                    if (result == true) {
                      setState(() {
                        _namecardListFuture = DatabaseHelper().fetchAllNamecards();
                      });
                    }
                  },
                ),
                ),
               );
            },
          );
        }
      ),
    );
  }
}