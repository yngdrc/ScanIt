import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:latlong2/latlong.dart';

import 'core/scan_result_dialog_widgets.dart';

class GeoDialog extends StatelessWidget {
  GeoDialog({super.key, required GeoPoint geoPoint}) {
    latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  late final LatLng latLng;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        DialogField(label: 'QR Type', values: [BarcodeType.geo.name]),
        DialogField(
          label: 'Coordinates',
          values: ['${latLng.latitude}, ${latLng.longitude}'],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: latLng,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'app.aventurine.scanit',
                ),
                MarkerLayer(
                  markers: [
                    Marker(point: latLng, child: Icon(Symbols.explore_nearby)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
