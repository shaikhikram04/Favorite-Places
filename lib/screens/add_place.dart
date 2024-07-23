import 'dart:io';

import 'package:favorite_places_app/widgets/image_input.dart';
import 'package:favorite_places_app/widgets/location_input.dart';
import 'package:favorite_places_app/provider/user_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;

  void showDialogBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Complete Info'),
        content: const Text('Please Enter place and its image.'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
        contentTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: const TextStyle().copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _savePlace() {
    final enteredText = _titleController.text;
    if (enteredText.isEmpty || _selectedImage == null) {
      showDialogBox();
      return;
    }

    ref
        .read(userPlacesProvider.notifier)
        .addPlace(enteredText, _selectedImage!);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            ImageInput(onPickImage: (image) {
              _selectedImage = image;
            }),
            const SizedBox(height: 10),
            const LocationInput(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _savePlace,
              label: const Text('Add Place'),
              icon: const Icon(Icons.add),
            )
          ],
        ),
      ),
    );
  }
}
