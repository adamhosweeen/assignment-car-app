import 'package:geolocator/geolocator.dart';

import 'package:assignment/model/malaysian_states.dart';

Future<String?> detectStateName() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 8),
      ),
    );
    return MalaysianStates.nearestTo(position.latitude, position.longitude);
  } catch (_) {
    return null;
  }
}
