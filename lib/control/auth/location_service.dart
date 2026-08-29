import 'package:geolocator/geolocator.dart';

import 'package:assignment/model/malaysian_states.dart';

/// Detect which Malaysian state the device is in, or null if location
/// services are off, permission is denied, or the fix times out. Callers fall
/// back to the manual state picker — this never throws.
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
