import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:learnflutter/widgets/location_input.dart';
import 'package:learnflutter/helperFunctions/get_address_from_latlng.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.initialLocation,
    this.isEditing = false,
  });
  final bool isEditing;
  final LatLng? initialLocation;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedLocation;
  String? _address;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      getAddressFromLatLng(_selectedLocation!.latitude, _selectedLocation!.longitude)
          .then((address) => setState(() => _address = address));
    }
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Your Location' : 'Pick Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _zoomOut,
            tooltip: 'Zoom out',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _zoomIn,
            tooltip: 'Zoom in',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _selectedLocation == null
                ? null
                : () {
                    Navigator.of(context).pop(_selectedLocation);
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialLocation ?? defaultLocation,
                initialZoom: widget.isEditing ? 13 : 7,
                onTap: (tapPosition, point) async {
                  final address = await getAddressFromLatLng(point.latitude, point.longitude);
                  setState(() {
                    _selectedLocation = point;
                    _address = address;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        child: const Icon(Icons.location_pin, color: Colors.red),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (_address != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Text(
                _address!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 