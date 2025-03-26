import 'package:flutter/material.dart';
import 'package:learnflutter/models/place.dart';

class NewPlaceScreen extends StatefulWidget {
  const NewPlaceScreen({super.key});

  @override
  State<NewPlaceScreen> createState() => _NewPlaceScreenState();
}

class _NewPlaceScreenState extends State<NewPlaceScreen> {
  var _enteredName = '';
  final _formKey = GlobalKey<FormState>();
  void _savePlace() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      _formKey.currentState?.save();
      if (_enteredName.trim().isNotEmpty) {
        Navigator.of(
          context,
        ).pop(Place(name: _enteredName, id: DateTime.now().toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: AppBar(title: const Text("Add new Place")),
      body: Form(
        key: _formKey,
        onChanged: () {
          setState(() {});  // Rebuild the widget
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
            ElevatedButton(
              onPressed: _formKey.currentState?.validate() ?? false
                  ? _savePlace
                  : null,
              child: const Text("Add Place"),
            ),
          ],
        ),
      ),
    );
  }
}
