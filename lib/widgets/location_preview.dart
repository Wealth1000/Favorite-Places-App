import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:learnflutter/models/place.dart';

class MapSnapshot extends StatefulWidget {
  const MapSnapshot({super.key, required this.location, this.size = 140});

  final PlaceLocation location;
  final double size;

  @override
  State<MapSnapshot> createState() => _MapSnapshotState();
}

class _MapSnapshotState extends State<MapSnapshot> {
  @override
  void didUpdateWidget(MapSnapshot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _shouldCapture = true;
      _mapImage = null;
      _captureMap(); // Re-capture when location changes
    }
  }

  final GlobalKey _mapKey = GlobalKey();
  ImageProvider? _mapImage;
  bool _shouldCapture = true;

  Future<void> _captureMap() async {
    try {
      if (!_shouldCapture || !mounted) return;

      final boundary =
          _mapKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Add small delay to ensure proper layout
      await Future.delayed(const Duration(milliseconds: 100));

      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return;

      // setState(() {
      //   _mapImage = MemoryImage(byteData.buffer.asUint8List());
      //   _shouldCapture = false;
      // });
      if (!mounted) return; // Check again before setState
      setState(() {
        _mapImage = MemoryImage(byteData.buffer.asUint8List());
        _shouldCapture = false;
      });
    } catch (e) {
      print('Error capturing map image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RepaintBoundary(
        key: _mapKey,
        child: ClipOval(
          child:
              _mapImage != null
                  ? Image(image: _mapImage!, fit: BoxFit.cover)
                  : IgnorePointer(
                    child: LocationPreview(
                      location: widget.location,
                      isInteractive: false,
                    ),
                  ),
        ),
      ),
    );
  }
}

// Modified LocationPreview to be more flexible
class LocationPreview extends StatelessWidget {
  const LocationPreview({
    super.key,
    required this.location,
    this.isInteractive = false,
  });

  final PlaceLocation location;
  final bool isInteractive;

  @override
  Widget build(BuildContext context) {
    final latLng = LatLng(location.latitude, location.longitude);

    return FlutterMap(
      options: MapOptions(
        initialCenter: latLng,
        initialZoom: 13,
        interactionOptions: InteractionOptions(
          flags: isInteractive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: latLng,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
