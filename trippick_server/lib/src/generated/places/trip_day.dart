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
import 'package:serverpod/serverpod.dart' as _is;
import 'package:trippick_server/src/generated/protocol.dart' as _ipy7wm2g;

/// One day of a saved trip: the chosen route as it was planned.
abstract class TripDay
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TripDay._({
    required this.day,
    required this.date,
    required this.mode,
    required this.kind,
    required this.placeIds,
    required this.stops,
    required this.travelMin,
    required this.cost,
  });

  factory TripDay({
    required int day,
    required String date,
    required String mode,
    required String kind,
    required List<int> placeIds,
    required List<String> stops,
    required int travelMin,
    required int cost,
  }) = _TripDayImpl;

  factory TripDay.fromJson(Map<String, dynamic> jsonSerialization) {
    return TripDay(
      day: jsonSerialization['day'] as int,
      date: jsonSerialization['date'] as String,
      mode: jsonSerialization['mode'] as String,
      kind: jsonSerialization['kind'] as String,
      placeIds: _ipy7wm2g.Protocol().deserialize<List<int>>(
        jsonSerialization['placeIds'],
      ),
      stops: _ipy7wm2g.Protocol().deserialize<List<String>>(
        jsonSerialization['stops'],
      ),
      travelMin: jsonSerialization['travelMin'] as int,
      cost: jsonSerialization['cost'] as int,
    );
  }

  /// 0 = first day.
  int day;

  /// yyyy-mm-dd
  String date;

  /// driving | walking | transit
  String mode;

  /// fast | hours | meal
  String kind;

  List<int> placeIds;

  /// "10:00 해운대 관광특구" per stop, so the trip reads without the places.
  List<String> stops;

  int travelMin;

  /// Estimated cost per person in won (admission + meals).
  int cost;

  /// Returns a shallow copy of this [TripDay]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TripDay copyWith({
    int? day,
    String? date,
    String? mode,
    String? kind,
    List<int>? placeIds,
    List<String>? stops,
    int? travelMin,
    int? cost,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TripDay',
      'day': day,
      'date': date,
      'mode': mode,
      'kind': kind,
      'placeIds': placeIds.toJson(),
      'stops': stops.toJson(),
      'travelMin': travelMin,
      'cost': cost,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TripDay',
      'day': day,
      'date': date,
      'mode': mode,
      'kind': kind,
      'placeIds': placeIds.toJson(),
      'stops': stops.toJson(),
      'travelMin': travelMin,
      'cost': cost,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TripDayImpl extends TripDay {
  _TripDayImpl({
    required int day,
    required String date,
    required String mode,
    required String kind,
    required List<int> placeIds,
    required List<String> stops,
    required int travelMin,
    required int cost,
  }) : super._(
         day: day,
         date: date,
         mode: mode,
         kind: kind,
         placeIds: placeIds,
         stops: stops,
         travelMin: travelMin,
         cost: cost,
       );

  /// Returns a shallow copy of this [TripDay]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TripDay copyWith({
    int? day,
    String? date,
    String? mode,
    String? kind,
    List<int>? placeIds,
    List<String>? stops,
    int? travelMin,
    int? cost,
  }) {
    return TripDay(
      day: day ?? this.day,
      date: date ?? this.date,
      mode: mode ?? this.mode,
      kind: kind ?? this.kind,
      placeIds: placeIds ?? this.placeIds.map((e0) => e0).toList(),
      stops: stops ?? this.stops.map((e0) => e0).toList(),
      travelMin: travelMin ?? this.travelMin,
      cost: cost ?? this.cost,
    );
  }
}
