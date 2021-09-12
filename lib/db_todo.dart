import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'toDo.dart';

class ToDoDatabase {
  static final ToDoDatabase instance = ToDoDatabase._init();

  static Database? _database;

  ToDoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('todo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
CREATE TABLE $tableToDo ( 
  ${ToDoFields.id} $idType, 
  ${ToDoFields.title} $textType,
  ${ToDoFields.desc} $textType,
  ${ToDoFields.date} $textType,
  ${ToDoFields.time} $textType,
  ${ToDoFields.isFinalised} $boolType,
  ${ToDoFields.color.toString()} $textType
  )
''');
  }

  Future<ToDo> create(ToDo toDo) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${ToDoFields.title}, ${ToDoFields.description}, ${ToDoFields.time}';
    // final values =
    //     '${json[ToDoFields.title]}, ${json[ToDoFields.description]}, ${json[ToDoFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');
    final id = await db.insert(tableToDo, toDo.toJson());
    return toDo.copy(id: id);
  }

  Future<ToDo> readToDo(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableToDo,
      columns: ToDoFields.values,
      where: '${ToDoFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ToDo.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<ToDo>> readAllToDo() async {
    final db = await instance.database;

    final orderBy = '${ToDoFields.date} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableToDo ORDER BY $orderBy');

    final result = await db.query(tableToDo, orderBy: orderBy);

    return result.map((json) => ToDo.fromJson(json)).toList();
  }

  Future<int> update(ToDo toDo) async {
    final db = await instance.database;

    return db.update(
      tableToDo,
      toDo.toJson(),
      where: '${ToDoFields.id} = ?',
      whereArgs: [toDo.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableToDo,
      where: '${ToDoFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
