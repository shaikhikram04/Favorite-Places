import 'package:favorite_places_app/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSnapshot extends StatelessWidget {
  const MapSnapshot({super.key, required this.location, this.onTapLocation});

  final PlaceLocation location;
  final void Function(TapPosition tapPosition, LatLng point)? onTapLocation;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
          initialCenter: LatLng(location.latitude, location.longitude),
          initialZoom: 17,
          onTap: onTapLocation,
          interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.none)),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(location.latitude, location.longitude),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 30.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
