import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnflutter/models/place.dart';
import 'package:learnflutter/providers/place_provider.dart';
import 'package:learnflutter/screens/new_place.dart';
// import 'package:learnflutter/screens/place_details.dart';
import 'package:learnflutter/widgets/places_list.dart';
//import 'package:learnflutter/widgets/places_list.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  void _addItem() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NewPlaceScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: AppBar(
        title: const Text("Your Places"),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: const Padding(
        padding:  EdgeInsets.all(8.0),
        child: PlacesList(),
      ), //PlacesList(places: []),
    );
  }
}
