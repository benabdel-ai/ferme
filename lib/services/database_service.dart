import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'troupeau_ovins.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE mouvements (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            qte INTEGER NOT NULL,
            date TEXT NOT NULL,
            remarque TEXT DEFAULT ''
          )
        ''');

        await database.execute('''
          CREATE TABLE depenses (
            id TEXT PRIMARY KEY,
            montant REAL NOT NULL,
            date TEXT NOT NULL,
            categorie TEXT NOT NULL,
            remarque TEXT DEFAULT ''
          )
        ''');

        await database.execute('''
          CREATE TABLE revenus (
            id TEXT PRIMARY KEY,
            montant REAL NOT NULL,
            date TEXT NOT NULL,
            categorie TEXT NOT NULL,
            remarque TEXT DEFAULT ''
          )
        ''');

        await _createAidTable(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createAidTable(database);
        }
      },
    );
  }

  Future<void> _createAidTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS aid_moutons (
        id TEXT PRIMARY KEY,
        numero TEXT NOT NULL UNIQUE,
        race TEXT NOT NULL,
        prixAchat REAL NOT NULL,
        coutRevient REAL NOT NULL DEFAULT 0,
        sold INTEGER NOT NULL DEFAULT 0,
        reserved INTEGER NOT NULL DEFAULT 0,
        prixVente REAL NOT NULL DEFAULT 0,
        acheteur TEXT DEFAULT '',
        createdAt TEXT NOT NULL,
        reservedAt TEXT,
        soldAt TEXT
      )
    ''');
  }

  Future<List<Mouvement>> getMouvements() async {
    final database = await db;
    final rows = await database.query('mouvements', orderBy: 'date ASC');
    return rows.map(Mouvement.fromMap).toList();
  }

  Future<void> insertMouvement(Mouvement mouvement) async {
    final database = await db;
    await database.insert(
      'mouvements',
      mouvement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMouvement(String id) async {
    final database = await db;
    await database.delete('mouvements', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Depense>> getDepenses() async {
    final database = await db;
    final rows = await database.query('depenses', orderBy: 'date DESC');
    return rows.map(Depense.fromMap).toList();
  }

  Future<void> insertDepense(Depense depense) async {
    final database = await db;
    await database.insert(
      'depenses',
      depense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDepense(String id) async {
    final database = await db;
    await database.delete('depenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Revenu>> getRevenus() async {
    final database = await db;
    final rows = await database.query('revenus', orderBy: 'date DESC');
    return rows.map(Revenu.fromMap).toList();
  }

  Future<void> insertRevenu(Revenu revenu) async {
    final database = await db;
    await database.insert(
      'revenus',
      revenu.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRevenu(String id) async {
    final database = await db;
    await database.delete('revenus', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AidMouton>> getAidMoutons() async {
    final database = await db;
    final rows = await database.query('aid_moutons', orderBy: 'createdAt DESC');
    return rows.map(AidMouton.fromMap).toList();
  }

  Future<void> insertAidMouton(AidMouton mouton) async {
    final database = await db;
    await database.insert(
      'aid_moutons',
      mouton.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateAidMouton(AidMouton mouton) async {
    final database = await db;
    await database.update(
      'aid_moutons',
      mouton.toMap(),
      where: 'id = ?',
      whereArgs: [mouton.id],
    );
  }

  Future<void> deleteAidMouton(String id) async {
    final database = await db;
    await database.delete('aid_moutons', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final database = await db;
    await database.delete('mouvements');
    await database.delete('depenses');
    await database.delete('revenus');
    await database.delete('aid_moutons');
  }
}
