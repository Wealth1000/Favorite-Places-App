import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnflutter/models/place.dart';
import 'package:learnflutter/providers/database_service.dart';

class PlacesNotifier extends StateNotifier<List<Place>> {
  final DatabaseService _dbService;

  PlacesNotifier(this._dbService) : super([]) {
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    state = await _dbService.getAllPlaces();
  }

  Future<void> addPlace(Place place) async {
    await _dbService.insertPlace(place);
    state = [...state, place];
  }

  Future<void> deletePlace(Place place) async {
    await _dbService.deletePlace(place.id);
    state = state.where((p) => p.id != place.id).toList();
  }

  Future<void> updatePlace(Place updatedPlace) async {
    await _dbService.updatePlace(updatedPlace);
    state =
        state.map((p) => p.id == updatedPlace.id ? updatedPlace : p).toList();
  }
}

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((
  ref,
) {
  return PlacesNotifier(DatabaseService.instance);
});

class SelectedPlaceNotifier extends StateNotifier<Place?> {
  SelectedPlaceNotifier() : super(null);

  void selectPlace(Place place) {
    state = place;
  }

  void clearSelection() {
    state = null;
  }
}

final selectedPlaceProvider =
    StateNotifierProvider<SelectedPlaceNotifier, Place?>(
      (ref) => SelectedPlaceNotifier(),
    );

final placeProvider = Provider.family<Place, String>((ref, id) {
  return ref.watch(placesProvider).firstWhere((place) => place.id == id);
});
