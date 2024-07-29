import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
        latitude: 27.17498, longitude: 78.04230, address: ''),
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'Pick your Location' : 'Your Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(_coordinate);
              },
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
