import 'package:favorite_places_app/models/place.dart';
import 'package:favorite_places_app/screens/map.dart';
import 'package:favorite_places_app/widgets/map_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<StatefulWidget> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    Position position;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    //* mark it as true -> after getPermission it true until location not get
    // coz it show loading animation until location get
    setState(() {
      _isGettingLocation = true;
    });

    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final lat = position.latitude;
    final lng = position.longitude;

    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemark[0];

    final address =
        '${place.street}, ${place.administrativeArea}, ${place.country}';

    // after getting location make it again false coz we get location now
    // we show location on screen
    setState(() {
      _isGettingLocation = false;
      _pickedLocation =
          PlaceLocation(latitude: lat, longitude: lng, address: address);
    });
    widget.onSelectLocation(_pickedLocation!);
  }

  void _saveLocation(PlaceLocation location) {
    setState(() {
      _pickedLocation = location;
    });
    widget.onSelectLocation(location);
  }

  void _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MapScreen(onSelectLocation: _saveLocation),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen.',
      style: Theme
          .of(context)
          .textTheme
          .bodyLarge!
          .copyWith(
        color: Theme
            .of(context)
            .colorScheme
            .onSurface,
      ),
    );

    if (_isGettingLocation == true) {
      previewContent = const CircularProgressIndicator();
    }

    if (_pickedLocation != null) {
      previewContent = MapSnapshot(
        location: _pickedLocation!,
        onTapLocation: (tapPosition, point) {},
      );
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get current location'),
            ),
            TextButton.icon(
              onPressed: _getUserLocation,
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        ),
      ],
    );
  }
}
