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
        return Dismissible(
          key: ValueKey(place.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            child: const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
          onDismissed: (direction) {
            ref.read(placesProvider.notifier).deletePlace(place);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha(51),
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                leading: Hero(
                  tag: place.id,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: FileImage(place.image),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                title: Text(
                  place.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  place.location.address,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(204),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha(153),
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
          ),
        );
      },
    );
  }
}
