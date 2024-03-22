import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:projet_spotify_gorouter/models/playlist-no-sql.dart';
import 'package:path/path.dart';

class DatabaseHelper extends ChangeNotifier{
  static const _databaseName = "MyDatabase.db";
  late Database db;

  Future<void> open() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE voitures (
            id INTEGER PRIMARY KEY,
            marque TEXT NOT NULL,
            modele TEXT,
            photo TEXT
          )
        ''');

        await db.execute("INSERT INTO voitures(marque, modele) VALUES('Renault', 'Clio')");
      },
    );
  }
  }

  // Future<List<Playlist>> getPlaylists() async {
  //   // Récupération des playlists depuis la base de données
  // }

  // Future<int> insertPlaylist(Playlist playlist) async {
  //   // Insertion d'une nouvelle playlist dans la base de données
  // }

  // Future<int> updatePlaylist(Playlist playlist) async {
  //   // Mise à jour d'une playlist dans la base de données
  // }

  // Future<int> deletePlaylist(int id) async {
  //   // Suppression d'une playlist de la base de données
  // }


