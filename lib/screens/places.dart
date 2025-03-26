import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnflutter/models/place.dart';
import 'package:learnflutter/providers/place_provider.dart';
import 'package:learnflutter/screens/new_place.dart';
import 'package:learnflutter/screens/place_details.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  void _addItem() async {
    final newItem = await Navigator.of(context).push<Place>(
      MaterialPageRoute(builder: (context) => const NewPlaceScreen()),
    );
    if (newItem == null) {
      return;
    }
    ref.read(placesProvider.notifier).addPlace(newItem);
  }

  void _deleteItem(Place place) {
    ref.read(placesProvider.notifier).deletePlace(place);
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);
    Widget content = const Center(
      child: Text(
        "You haven't added any places yet. Add some!",
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
    if (places.isNotEmpty) {
      content = ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(places[index].id),
            onDismissed: (direction) {
              _deleteItem(places[index]);
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
              title: Text(places[index].name),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => PlaceDetails(place: places[index]),
                  ),
                );
              },
            ),
          );
        },
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: AppBar(
        title: const Text("Your Places"),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
