import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnflutter/models/place.dart';

class PlaceDetails extends ConsumerWidget {
  const PlaceDetails({super.key, required this.place});
  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: Center(
        child: Text(place.name, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
