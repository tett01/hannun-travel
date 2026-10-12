/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:trippick_client/src/protocol/protocol.dart' as _in7lcnwt;
import '../places/trip_day.dart' as _i8hjghyn;

/// A trip a traveler saved from the route planner, e.g. "부산 여행".
/// Kept per device (no sign-in yet).
abstract class Trip
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Trip._({
    this.id,
    required this.deviceId,
    required this.title,
    required this.area,
    required this.days,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Trip({
    int? id,
    required String deviceId,
    required String title,
    required String area,
    required List<_i8hjghyn.TripDay> days,
    DateTime? createdAt,
  }) = _TripImpl;

  factory Trip.fromJson(Map<String, dynamic> jsonSerialization) {
    return Trip(
      id: jsonSerialization['id'] as int?,
      deviceId: jsonSerialization['deviceId'] as String,
      title: jsonSerialization['title'] as String,
      area: jsonSerialization['area'] as String,
      days: _in7lcnwt.Protocol().deserialize<List<_i8hjghyn.TripDay>>(
        jsonSerialization['days'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String deviceId;

  String title;

  /// Area shown when it was planned, e.g. "부산 해운대".
  String area;

  List<_i8hjghyn.TripDay> days;

  DateTime createdAt;

  /// Returns a shallow copy of this [Trip]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Trip copyWith({
    int? id,
    String? deviceId,
    String? title,
    String? area,
    List<_i8hjghyn.TripDay>? days,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Trip',
      if (id != null) 'id': id,
      'deviceId': deviceId,
      'title': title,
      'area': area,
      'days': days.toJson(valueToJson: (v) => v.toJson()),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Trip',
      if (id != null) 'id': id,
      'deviceId': deviceId,
      'title': title,
      'area': area,
      'days': days.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TripImpl extends Trip {
  _TripImpl({
    int? id,
    required String deviceId,
    required String title,
    required String area,
    required List<_i8hjghyn.TripDay> days,
    DateTime? createdAt,
  }) : super._(
         id: id,
         deviceId: deviceId,
         title: title,
         area: area,
         days: days,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Trip]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Trip copyWith({
    Object? id = _Undefined,
    String? deviceId,
    String? title,
    String? area,
    List<_i8hjghyn.TripDay>? days,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id is int? ? id : this.id,
      deviceId: deviceId ?? this.deviceId,
      title: title ?? this.title,
      area: area ?? this.area,
      days: days ?? this.days.map((e0) => e0.copyWith()).toList(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
