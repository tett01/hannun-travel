import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Accessed from the app as `client.trip`. Trips belong to the random id
/// the app keeps on the device, since there is no sign-in yet.
class TripEndpoint extends Endpoint {
  static void _checkDevice(String deviceId) {
    if (deviceId.length < 16 || deviceId.length > 64) {
      throw ArgumentError.value(deviceId, 'deviceId', 'Invalid device id');
    }
  }

  /// Saves [trip] for [deviceId] and returns it with its id.
  Future<Trip> save(Session session, String deviceId, Trip trip) async {
    _checkDevice(deviceId);
    final title = trip.title.trim();
    if (title.isEmpty || trip.days.isEmpty) {
      throw ArgumentError('A trip needs a title and at least one day');
    }
    return Trip.db.insertRow(
      session,
      trip.copyWith(
        id: null,
        deviceId: deviceId,
        title: title.substring(0, title.length.clamp(0, 60)),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Trips saved on [deviceId], newest first.
  Future<List<Trip>> list(Session session, String deviceId) {
    _checkDevice(deviceId);
    return Trip.db.find(
      session,
      where: (t) => t.deviceId.equals(deviceId),
      orderBy: (t) => t.createdAt.desc(),
      limit: 100,
    );
  }

  /// Deletes trip [id] if it belongs to [deviceId].
  Future<bool> delete(Session session, String deviceId, int id) async {
    _checkDevice(deviceId);
    final removed = await Trip.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id) & t.deviceId.equals(deviceId),
    );
    return removed.isNotEmpty;
  }
}
