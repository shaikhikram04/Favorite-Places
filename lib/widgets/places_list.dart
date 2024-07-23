import 'package:favorite_places_app/models/place.dart';
import 'package:favorite_places_app/screens/place_detail.dart';
import 'package:flutter/material.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({super.key, required this.placeList});
  final List<Place> placeList;

  @override
  Widget build(BuildContext context) {
    if (placeList.isEmpty) {
      return Center(
        child: Text(
          'No places added yet',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      );
    }

    return ListView.builder(
      itemCount: placeList.length,
      itemBuilder: (BuildContext context, int index) => ListTile(
        leading: CircleAvatar(
          backgroundImage: FileImage(placeList[index].image),
          radius: 24,
        ),
        title: Text(
          placeList[index].title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => PlaceDetailScreen(place: placeList[index]),
          ));
        },
      ),
    );
  }
}
