import 'dart:io';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlaceLocation {
  const PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          address == other.address;

  @override
  int get hashCode => Object.hash(latitude, longitude, address);
}

class Place {
  Place({
    required this.name,
    required this.image,
    required this.location,
    String? id, // Add optional ID parameter
  }) : id = id ?? uuid.v4(); // Generate new ID only if not provided

  final String id;
  final String name;
  final File image;
  final PlaceLocation location;

  // Modified copyWith method
  Place copyWith({
    String? name,
    File? image,
    PlaceLocation? location,
  }) {
    return Place(
      id: id, // Preserve original ID
      name: name ?? this.name,
      image: image ?? this.image,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Place &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          image.path == other.image.path &&
          location == other.location;

  @override
  int get hashCode => Object.hash(id, name, image.path, location);
}