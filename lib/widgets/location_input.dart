import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:location/location.dart' as loc;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:learnflutter/screens/map_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Default location (center of Ghana)
const defaultLocation = LatLng(7.9465, -1.0232);

String formatAddress(Map<String, dynamic> data) {
  final address = data['address'];
  if (address == null) return '';

  // Try to get the most relevant parts in order of preference
  final parts = [
    address['road'],           // Street name
    address['suburb'],         // Suburb/neighborhood
    address['city'],           // City
    address['town'],           // Town (if city is not available)
    address['state_district'], // District
    address['state'],          // State/Region
    address['country'],        // Country
  ].where((part) => part != null && part.isNotEmpty).toList();

  return parts.join(', ');
}

class LocationInput extends StatefulWidget {
  const LocationInput({
    super.key,
    required this.onSelectLocation,
  });

  final void Function(LatLng location, String address) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  var _isGettingLocation = false;
  String? _address;
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
        headers: {'User-Agent': 'GreatPlaces/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['address'] != null) {
          final formattedAddress = formatAddress(data);
          if (formattedAddress.isNotEmpty) {
            return formattedAddress;
          }
        }
      }
      
      return "Location: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
    } catch (e) {
      return "Location: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
    }
  }
void _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check if location services are enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are required')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enable location permissions in app settings'),
          ),
        );
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition();
      final LatLng latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = latLng;
      });

      final address = await getAddressFromLatLng(latLng.latitude, latLng.longitude);
      setState(() {
        _address = address;
        _isGettingLocation = false;
      });

      widget.onSelectLocation(latLng, _address!);
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isGettingLocation = false;
      });
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get current location')),
      );
    }
  }
  // void _getCurrentLocation() async {
  //   setState(() {
  //     _isGettingLocation = true;
  //   });
  //   print("Trying to get current location");

  //   loc.Location location = loc.Location();

  //   bool serviceEnabled;
  //   loc.PermissionStatus permissionGranted;
  //   loc.LocationData locationData;

  //   serviceEnabled = await location.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await location.requestService();
  //     if (!serviceEnabled) {
  //       return;
  //     }
  //   }

  //   permissionGranted = await location.hasPermission();
  //   if (permissionGranted == loc.PermissionStatus.denied) {
  //     permissionGranted = await location.requestPermission();
  //     if (permissionGranted != loc.PermissionStatus.granted) {
  //       return;
  //     }
  //   }
  //   print("Permission Granted");

  //   locationData = await location.getLocation();
  //   final latLng = LatLng(locationData.latitude!, locationData.longitude!);
  //   print("Gotten location");
  //   setState(() {
  //     _selectedLocation = latLng;
  //   });
  //   print("Selected Location succesfully");

  //   final address = await getAddressFromLatLng(latLng.latitude, latLng.longitude);
  //   setState(() {
  //     _address = address;
  //     _isGettingLocation = false;
  //   });

  //   widget.onSelectLocation(latLng, _address!);
  // }

  Future<void> _selectOnMap() async {
    final LatLng? selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(initialLocation: _selectedLocation),
      ),
    );

    if (selectedLocation == null) {
      return;
    }

    setState(() {
      _selectedLocation = selectedLocation;
    });

    final address = await getAddressFromLatLng(selectedLocation.latitude, selectedLocation.longitude);
    setState(() {
      _address = address;
    });

    widget.onSelectLocation(selectedLocation, _address!);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      "No location chosen",
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    } else if (_selectedLocation != null) {
      previewContent = SizedBox(
        height: 178,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation!,
            initialZoom: 7,
            onTap: (tapPosition, point) async {
              final address = await getAddressFromLatLng(point.latitude, point.longitude);
              setState(() {
                _selectedLocation = point;
                _address = address;
                _mapController.move(point, _mapController.camera.zoom);
              });
              widget.onSelectLocation(point, _address!);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
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
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            alignment: Alignment.center,
            height: 178,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.primary.withAlpha(511),
              ),
            ),
            child: previewContent,
          ),
        ),
        if (_address != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              _address!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text("Get current location"),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              label: const Text("Select on map"),
              icon: const Icon(Icons.map),
            ),
          ],
        ),
      ],
    );
  }
}
