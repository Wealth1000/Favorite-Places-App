import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnflutter/models/place.dart';
import 'package:learnflutter/providers/place_provider.dart';
import 'package:learnflutter/screens/place_details.dart';

class PlacesList extends ConsumerWidget {
  const PlacesList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void deleteItem(Place place) {
      ref.read(placesProvider.notifier).deletePlace(place);
    }

    final places = ref.watch(placesProvider);
    if (places.isEmpty) {
      return Center(
        child: Text(
          "No places added yet",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Dismissible(
            key: ValueKey(place.id),
            onDismissed: (direction) {
              deleteItem(place);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 26,
                backgroundImage: FileImage(place.image),
              ),
              title: Text(place.name),
              subtitle: Text(
                place.location.address,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => PlaceDetails(placeId: place.id),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
