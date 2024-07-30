import 'dart:io';

import 'package:favorite_places_app/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//* The path_provider package is used for accessing commonly used locations on the filesystem,
// such as the temporary directory and the application’s documents directory.
// It provides platform-agnostic access to these directories, allowing you to save files
// in locations appropriate for the operating system your app is running on.
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address, TEXT)');
    },
    version: 1,
  );

  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  void loadPlaces() async {
    final db = await _getDatabase();
    //* get data from database
    final data = await db.query('user_places');

    final places = data
        .map((row) => Place(
              id: row['id'] as String,
              title: row['title'] as String,
              image: File(row['image'] as String),
              location: PlaceLocation(
                  latitude: row['lat'] as double,
                  longitude: row['lng'] as double,
                  address: row['address'] as String),
            ))
        .toList();

    state = places;
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths
        .getApplicationDocumentsDirectory(); // getting directory in which app data are store
    final fileName =
        path.basename(image.path); // getting name of file of a image
    final copiedImage = await image.copy(
        '${appDir.path}/$fileName'); // copy image on that path into a directory of filename

    final newPlace =
        Place(title: title, image: copiedImage, location: location);

    final db = await _getDatabase();
    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });

    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
