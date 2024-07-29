import 'package:favorite_places_app/models/place.dart';
import 'package:favorite_places_app/screens/map.dart';
import 'package:favorite_places_app/widgets/map_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<StatefulWidget> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  Future<void> _savePlace(double lat, double lng) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemark[0];

    final address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

    // after getting location make it again false coz we get location now
    // we show location on screen
    setState(() {
      _isGettingLocation = false;
      _pickedLocation =
          PlaceLocation(latitude: lat, longitude: lng, address: address);
    });
    widget.onSelectLocation(_pickedLocation!);
  }

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
      _pickedLocation = null;
      _isGettingLocation = true;
    });

    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _savePlace(position.latitude, position.longitude);
  }

  void _getMapLocation() async {
    PlaceLocation? previousLocation = _pickedLocation;

    if (!mounted) {
      return;
    }

    setState(() {
      _pickedLocation = null;
      _isGettingLocation = true;
    });

    final selectedLocation =
        await Navigator.of(context).push<LatLng>(MaterialPageRoute(
      builder: (context) => (previousLocation == null)
          ? const MapScreen()
          : MapScreen(
              location: previousLocation,
            ),
    ));

    if (selectedLocation == null) {
      setState(() {
        _isGettingLocation = false;
      });
      return;
    }

    _savePlace(selectedLocation.latitude, selectedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen.',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );

    if (_isGettingLocation == true) {
      previewContent = const CircularProgressIndicator();
    }

    if (_pickedLocation != null) {
      previewContent = MapSnapshot(
        location: _pickedLocation!,
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
              onPressed: _getMapLocation,
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        ),
      ],
    );
  }
}
