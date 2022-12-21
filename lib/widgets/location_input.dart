import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../screens/map_screen.dart';
import '../helpers/location_helper.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({Key? key}) : super(key: key);

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;
  Location location = Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future<void> _getUserCurrentLocation() async {
    try {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      //getting user location coordinates
      _locationData = await location.getLocation();
      print(_locationData);

      //setting user location map preview
      final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
        latitude: _locationData.latitude,
        longitude: _locationData.longitude,
      );
      setState(() {
        _previewImageUrl = staticMapImageUrl;
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => const MapScreen(
          isSelecting: true,
        ),
      ),
    );
    if (selectedLocation == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: mediaQuery.height * .30,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          child: _previewImageUrl == null
              ? const Text(
                  'No Location Chosen.',
                  textAlign: TextAlign.center,
                )
              : Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _getUserCurrentLocation,
              icon: const Icon(Icons.location_on_rounded),
              label: const Text('Current location'),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map_rounded),
              label: const Text('Select on Map'),
            )
          ],
        )
      ],
    );
  }
}
