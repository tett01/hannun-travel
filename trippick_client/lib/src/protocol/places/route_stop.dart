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

/// One stop of a planned route. Times are minutes after midnight.
abstract class RouteStop
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RouteStop._({
    required this.placeId,
    required this.travelMin,
    required this.distanceM,
    required this.arriveMin,
    required this.waitMin,
    required this.leaveMin,
    this.issue,
    this.fee,
  });

  factory RouteStop({
    required int placeId,
    required int travelMin,
    required int distanceM,
    required int arriveMin,
    required int waitMin,
    required int leaveMin,
    String? issue,
    int? fee,
  }) = _RouteStopImpl;

  factory RouteStop.fromJson(Map<String, dynamic> jsonSerialization) {
    return RouteStop(
      placeId: jsonSerialization['placeId'] as int,
      travelMin: jsonSerialization['travelMin'] as int,
      distanceM: jsonSerialization['distanceM'] as int,
      arriveMin: jsonSerialization['arriveMin'] as int,
      waitMin: jsonSerialization['waitMin'] as int,
      leaveMin: jsonSerialization['leaveMin'] as int,
      issue: jsonSerialization['issue'] as String?,
      fee: jsonSerialization['fee'] as int?,
    );
  }

  int placeId;

  /// Travel from the previous stop (or the start point) to here.
  int travelMin;

  int distanceM;

  int arriveMin;

  /// Waiting for opening time or the end of a break.
  int waitMin;

  int leaveMin;

  /// closed_day | closed_hours | null when the place should be open.
  String? issue;

  /// Admission fee in won from the official info (0 = free, null = unknown).
  int? fee;

  /// Returns a shallow copy of this [RouteStop]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RouteStop copyWith({
    int? placeId,
    int? travelMin,
    int? distanceM,
    int? arriveMin,
    int? waitMin,
    int? leaveMin,
    String? issue,
    int? fee,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RouteStop',
      'placeId': placeId,
      'travelMin': travelMin,
      'distanceM': distanceM,
      'arriveMin': arriveMin,
      'waitMin': waitMin,
      'leaveMin': leaveMin,
      if (issue != null) 'issue': issue,
      if (fee != null) 'fee': fee,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RouteStop',
      'placeId': placeId,
      'travelMin': travelMin,
      'distanceM': distanceM,
      'arriveMin': arriveMin,
      'waitMin': waitMin,
      'leaveMin': leaveMin,
      if (issue != null) 'issue': issue,
      if (fee != null) 'fee': fee,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RouteStopImpl extends RouteStop {
  _RouteStopImpl({
    required int placeId,
    required int travelMin,
    required int distanceM,
    required int arriveMin,
    required int waitMin,
    required int leaveMin,
    String? issue,
    int? fee,
  }) : super._(
         placeId: placeId,
         travelMin: travelMin,
         distanceM: distanceM,
         arriveMin: arriveMin,
         waitMin: waitMin,
         leaveMin: leaveMin,
         issue: issue,
         fee: fee,
       );

  /// Returns a shallow copy of this [RouteStop]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RouteStop copyWith({
    int? placeId,
    int? travelMin,
    int? distanceM,
    int? arriveMin,
    int? waitMin,
    int? leaveMin,
    Object? issue = _Undefined,
    Object? fee = _Undefined,
  }) {
    return RouteStop(
      placeId: placeId ?? this.placeId,
      travelMin: travelMin ?? this.travelMin,
      distanceM: distanceM ?? this.distanceM,
      arriveMin: arriveMin ?? this.arriveMin,
      waitMin: waitMin ?? this.waitMin,
      leaveMin: leaveMin ?? this.leaveMin,
      issue: issue is String? ? issue : this.issue,
      fee: fee is int? ? fee : this.fee,
    );
  }
}
