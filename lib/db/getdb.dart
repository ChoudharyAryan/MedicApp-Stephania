import 'package:sqflite/sqflite.dart';

Future<Database> getDb() async {
  String dbPath = '${await getDatabasesPath()}tasks.db';
  return await openDatabase(dbPath, version: 1,
      onCreate: (Database db, int version) async {
    await db.execute('''
  create table tasks ( 
    id integer primary key autoincrement, 
    data text not null,
    start_m INTEGER not null,
    start_d INTEGER not null,
    start_y INTEGER not null,
    end_m INTEGER not null,
    end_d INTEGER not null,
    end_y INTEGER not null,
    createdAt text not null)
  ''');
  });
}
