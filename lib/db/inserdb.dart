import 'package:sqflite/sqflite.dart';

import 'getdb.dart';

Future insertMedicinsforDate({
  required String data,
  required int start_m,
  required int start_d,
  required int start_y,
  required int end_m,
  required int end_d,
  required int end_y,
  required String createdAt,
}) async {
  Database db = await getDb();

  print(data);
  print(start_m);
  print(start_d);
  print(start_y);
  print(end_m);
  print(end_d);
  print(end_y);
  print(createdAt);

  await db.insert("tasks", {
    "data": data,
    "start_m": start_m,
    "start_d": start_d,
    "start_y": start_y,
    "end_m": end_m,
    "end_d": end_d,
    "end_y": end_y,
    "createdAt": createdAt
  });
  await db.close();
}

Future deleteTask(int id) async {
  Database db = await getDb();
  await db.delete("tasks", where: "id = $id");
  db.close();
}
