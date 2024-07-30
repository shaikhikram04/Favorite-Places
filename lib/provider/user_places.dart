import 'dart:io';

import 'package:favorite_places_app/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//* The path_provider package is used for accessing commonly used locations on the filesystem,
// such as the temporary directory and the application’s documents directory.
// It provides platform-agnostic access to these directories, allowing you to save files
// in locations appropriate for the operating system your app is running on.
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths
        .getApplicationDocumentsDirectory(); // getting directory in which app data are store
    final fileName =
        path.basename(image.path); // getting name of file of a image
    final copiedImage = await image.copy(
        '${appDir.path}/$fileName'); // copy image on that path into a directory of filename

    final newPlace = Place(title: title, image: image, location: location);
    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
