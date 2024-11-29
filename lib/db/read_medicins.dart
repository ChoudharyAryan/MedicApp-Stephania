import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import 'getdb.dart';

Future<List<Map<String, Object?>>> readMedicinsforDate(
    int date, int month, int year) async {
  Database db = await getDb();
  log("And This Is my DataBase DB : ${db.toString()}");
  List<Map<String, dynamic>> schema =
      await db.rawQuery("PRAGMA table_info(tasks)");
  log(schema.toString());
  List<Map<String, Object?>> data = await db.query(
    "tasks",
    orderBy: "id",
    where: """
      (start_y < ? OR (start_y = ? AND (start_m < ? OR (start_m = ? AND start_d <= ?))))
      AND
      (end_y > ? OR (end_y = ? AND (end_m > ? OR (end_m = ? AND end_d >= ?))))
    """,
    whereArgs: [year, year, month, month, date, year, year, month, month, date],
  );
  return data;
}
