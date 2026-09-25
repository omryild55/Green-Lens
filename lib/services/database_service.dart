import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/history_model.dart';

class DatabaseService {
  static Database? _db;
  static const String tabloAdi = 'plant_history';

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    // Veritabanı adını v4 yaptık ki her şey sıfırdan ve hatasız kurulsun
    String yol = join(await getDatabasesPath(), 'greenlens_v4.db'); 
    return await openDatabase(
      yol,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tabloAdi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT,
            scientificName TEXT,
            commonNames TEXT,
            confidence REAL,
            date TEXT,
            isFavorite INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  static Future<int> insertHistory(HistoryModel model) async {
    try {
      final veritabani = await db;
      return await veritabani.insert(tabloAdi, model.toMap());
    } catch (e) {
      print("Ekleme Hatası: $e");
      return -1;
    }
  }

  static Future<List<HistoryModel>> getAllHistory() async {
    try {
      final veritabani = await db;
      final List<Map<String, dynamic>> maps = await veritabani.query(tabloAdi, orderBy: 'date DESC');
      return List.generate(maps.length, (i) => HistoryModel.fromMap(maps[i]));
    } catch (e) {
      print("Listeleme Hatası: $e");
      return [];
    }
  }

  static Future<int> deleteHistory(int id) async {
    final veritabani = await db;
    return await veritabani.delete(tabloAdi, where: 'id = ?', whereArgs: [id]);
  }
}