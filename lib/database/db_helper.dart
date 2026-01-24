import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'notes_database.db');
    return await openDatabase(
      path,
      version: 2, // Upgraded version for display_order
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            updated_at TEXT,
            display_order INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE notes ADD COLUMN display_order INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    // Get the current max display order to put new note at the top if needed, 
    // or just use 0. But for reordering, let's put new notes at index 0 and increment others?
    // Actually, let's just insert it and we'll handle reordering in the UI.
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'display_order ASC, updated_at DESC', // Sort by custom order first
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> updateNotesOrder(List<Note> notes) async {
    final db = await database;
    Batch batch = db.batch();
    for (int i = 0; i < notes.length; i++) {
      batch.update(
        'notes',
        {'display_order': i},
        where: 'id = ?',
        whereArgs: [notes[i].id],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
