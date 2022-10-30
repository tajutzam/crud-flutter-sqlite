import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as m;

class SqlHelper {
  // membuat database catatan

  static Future<void> createDatabase(sql.Database database) async {
    await database.execute("""
    create table catatan(
      id INTEGER PRIMARY KEY autoincrement NOT NULL,
      judul TEXT ,
      deskripsi TEXT
    )
""");
  }

  static Future<sql.Database> db() async {
    var databasePath = await sql.getDatabasesPath();
    String path = m.join(databasePath, "catatans.db");
    return await sql.openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => createDatabase(db),
    );
  }

  static Future<int> deleteById(id) async {
    sql.Database database = await SqlHelper.db();
    return await database.delete('catatan', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertData(String judul, String deskripsi) async {
    sql.Database database = await SqlHelper.db();
    Map<String, String> data = {'judul': judul, 'deskripsi': deskripsi};
    return database.insert('catatan', data);
  }

  static Future<List<Map<String, Object?>>> getData() async {
    sql.Database database = await SqlHelper.db();
    var data = await database.query('catatan');
    return data;
  }

  static Future<int> updateData(String judul, String description, id) async {
    sql.Database database = await SqlHelper.db();
    Map<String, String> data = {'judul': judul, 'deskripsi': description};
    return await database
        .update('catatan', data, where: 'id =?', whereArgs: [id]);
  }

  static Future<List<Map<String, Object?>>> getById(id) async {
    sql.Database database = await SqlHelper.db();
    return await database.query('catatan', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, Object?>>> searchData(String judul) async {
    final sql.Database database = await SqlHelper.db();
    return await database
        .query('catatan', where: 'judul LIKE ?', whereArgs: ['%${judul}%']);
  }
}
