import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Accessed from the app as `client.report`.
class ReportEndpoint extends Endpoint {
  static const kinds = {
    'closed_forever',
    'hours',
    'break_time',
    'closed_day',
    'other',
  };

  /// Reports older than this no longer show, since the info may be fixed.
  static const recent = Duration(days: 90);

  /// Saves a report that [placeId] differs from the shown info and returns
  /// the place's recent reports.
  Future<List<PlaceReport>> add(
    Session session,
    int placeId,
    String kind,
    String note,
  ) async {
    if (!kinds.contains(kind)) {
      throw ArgumentError.value(kind, 'kind', 'Unknown report kind');
    }
    if (await Place.db.findById(session, placeId) == null) {
      throw ArgumentError.value(placeId, 'placeId', 'No such place');
    }
    final text = note.trim();
    await PlaceReport.db.insertRow(
      session,
      PlaceReport(
        placeId: placeId,
        kind: kind,
        note: text.isEmpty
            ? null
            : text.substring(0, text.length.clamp(0, 300)),
      ),
    );
    return list(session, placeId);
  }

  /// Reports for [placeId] from the last [recent] days, newest first.
  Future<List<PlaceReport>> list(Session session, int placeId) {
    final since = DateTime.now().toUtc().subtract(recent);
    return PlaceReport.db.find(
      session,
      where: (t) => t.placeId.equals(placeId) & (t.createdAt > since),
      orderBy: (t) => t.createdAt.desc(),
      limit: 20,
    );
  }
}
