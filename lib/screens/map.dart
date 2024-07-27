import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import '../models/place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location =
        const PlaceLocation(latitude: 37.422, longitude: -122.084, address: ''),
    this.isSelecting = true,
    this.onSelectLocation,
  });

  final PlaceLocation location;
  final bool isSelecting;
  final void Function(PlaceLocation location)? onSelectLocation;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _coordinate;

  @override
  void initState() {
    _coordinate = LatLng(widget.location.latitude, widget.location.longitude);
    super.initState();
  }

  void _markLocation(LatLng newCoordinate) {
    if (widget.isSelecting == false) {
      return;
    }
    setState(() {
      _coordinate = newCoordinate;
    });
  }

  void _saveLocation() async {
    final lat = _coordinate.latitude;
    final lng = _coordinate.longitude;

    List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
    Placemark place = placemark[0];

    final address =
        '${place.street}, ${place.administrativeArea}, ${place.country}';

    widget.onSelectLocation!(
        PlaceLocation(latitude: lat, longitude: lng, address: address));

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'Pick your Location' : 'Your Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: _saveLocation,
              icon: const Icon(Icons.save),
            )
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _coordinate,
          initialZoom: 13,
          onLongPress: (tapPosition, point) => _markLocation(point),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          MarkerLayer(markers: [
            Marker(
              point: _coordinate,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          ])
        ],
      ),
    );
  }
}
