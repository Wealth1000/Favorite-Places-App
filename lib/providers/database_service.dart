import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:learnflutter/models/place.dart';

class DatabaseService {
  static const _dbName = 'places.db';
  static const _dbVersion = 1;
  static const _tableName = 'places';

  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertPlace(Place place) async {
    final db = await database;
    return db.insert(_tableName, _placeToMap(place));
  }

  Future<List<Place>> getAllPlaces() async {
    final db = await database;
    final maps = await db.query(_tableName);
    return maps.map(_mapToPlace).toList();
  }

  Future<int> updatePlace(Place place) async {
    final db = await database;
    return db.update(
      _tableName,
      _placeToMap(place),
      where: 'id = ?',
      whereArgs: [place.id],
    );
  }

  Future<int> deletePlace(String id) async {
    final db = await database;
    return db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _placeToMap(Place place) {
    return {
      'id': place.id,
      'name': place.name,
      'imagePath': place.image.path,
      'latitude': place.location.latitude,
      'longitude': place.location.longitude,
      'address': place.location.address,
    };
  }

  Place _mapToPlace(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      name: map['name'],
      image: File(map['imagePath']),
      location: PlaceLocation(
        latitude: map['latitude'],
        longitude: map['longitude'],
        address: map['address'],
      ),
    );
  }
}