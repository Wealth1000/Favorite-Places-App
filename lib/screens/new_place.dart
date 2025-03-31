import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learnflutter/models/place.dart';
import 'package:learnflutter/providers/place_provider.dart';
import 'package:learnflutter/widgets/image_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnflutter/widgets/location_input.dart';

class NewPlaceScreen extends ConsumerStatefulWidget {
  const NewPlaceScreen({super.key});

  @override
  ConsumerState<NewPlaceScreen> createState() => _NewPlaceScreenState();
}

class _NewPlaceScreenState extends ConsumerState<NewPlaceScreen> {
  var _enteredName = '';
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  PlaceLocation? _finalLocation;
  void _savePlace() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _formKey.currentState?.save();
      if (_enteredName.isEmpty || _selectedImage == null) {
        return;
      }
      if (_enteredName.trim().isNotEmpty || _selectedImage != null) {
        ref
            .read(placesProvider.notifier)
            .addPlace(Place(name: _enteredName, image: _selectedImage!, location: _finalLocation!));
        Navigator.of(context).pop(); // Just pop without returning value
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: AppBar(title: const Text("Add new Place")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          onChanged: () {
            setState(() {}); // Rebuild the widget
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: TextFormField(
                  autofocus: true,
                  maxLength: 50,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    label: Text("Name of place"),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final trimmedValue = value?.trim() ?? '';
                    if (trimmedValue.isEmpty ||
                        trimmedValue.length <= 1 ||
                        trimmedValue.length > 50) {
                      return "Must be between 1 and 50 characters";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _enteredName = newValue?.trim() ?? '';
                  },
                ),
              ),
              const SizedBox(height: 10),
              ImageInput(
                onSelectImage: (image) {
                  _selectedImage = image;
                },
              ),
              const SizedBox(height: 20),
              LocationInput(
                onSelectLocation: (location, address) {
                  setState(() {
                    _finalLocation = PlaceLocation(
                      latitude: location.latitude,
                      longitude: location.longitude,
                      address: address,
                    );
                  });
                },
              ),
              const SizedBox(height: 10),
              FloatingActionButton.extended(
                onPressed:
                    _formKey.currentState?.validate() ?? false
                        ? _savePlace
                        : null,
                label: const Text("Add Place"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
