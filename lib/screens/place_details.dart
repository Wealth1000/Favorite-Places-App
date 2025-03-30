import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:learnflutter/models/place.dart';
import 'package:learnflutter/screens/map_screen.dart';
import 'package:learnflutter/widgets/location_preview.dart';
import 'package:learnflutter/providers/place_provider.dart'; // Added import statement
import 'package:learnflutter/helperFunctions/get_address_from_latlng.dart';

class PlaceDetails extends ConsumerStatefulWidget {
  const PlaceDetails({super.key, required this.placeId}); // Changed parameter
  final String placeId;
  @override
  ConsumerState<PlaceDetails> createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends ConsumerState<PlaceDetails> {
  // Now tracking by ID
  @override
  Widget build(BuildContext context) {
    final place = ref.watch(placeProvider(widget.placeId));
    final places = ref.watch(placesProvider);
    if (!places.any((p) => p.id == widget.placeId)) {
      Navigator.pop(context); // Return if place was deleted
      return const SizedBox.shrink();
    }
    print(place.location.address);
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: Stack(
        children: [
          Image.file(
            place.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    final updatedLocation = await Navigator.of(
                      context,
                    ).push<LatLng?>(
                      MaterialPageRoute(
                        builder:
                            (ctx) => MapScreen(
                              initialLocation: LatLng(
                                place.location.latitude,
                                place.location.longitude,
                              ),
                              isEditing: true,
                            ),
                      ),
                    );
                    if (updatedLocation != null) {
                      // Create a new Place instance with the updated location
                      final addressOfLocation = await getAddressFromLatLng(
                        updatedLocation.latitude,
                        updatedLocation.longitude,
                      );
                      final PlaceLocation updatedConvertedLocation =
                          PlaceLocation(
                            latitude: updatedLocation.latitude,
                            longitude: updatedLocation.longitude,
                            address: addressOfLocation,
                          );
                      final updatedPlace = place.copyWith(
                        location: updatedConvertedLocation,
                      );
                      ref
                          .read(placesProvider.notifier)
                          .updatePlace(updatedPlace);
                    }
                  },
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      children: [
                        MapSnapshot(
                          location: place.location,
                          key: ValueKey(place.location.hashCode),
                        ),
                        // Add visual feedback
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withAlpha(51),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    place.location.address,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
