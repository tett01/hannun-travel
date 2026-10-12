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
import '../places/route_stop.dart' as _ii2p07ww;

/// A visiting order for the places a traveler picked.
abstract class RoutePlan
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RoutePlan._({
    required this.kind,
    required this.stops,
    required this.travelMin,
    required this.distanceM,
    required this.endMin,
    required this.issues,
    required this.feeTotal,
    required this.feeUnknown,
    required this.mealEstimate,
    required this.measured,
  });

  factory RoutePlan({
    required String kind,
    required List<_ii2p07ww.RouteStop> stops,
    required int travelMin,
    required int distanceM,
    required int endMin,
    required int issues,
    required int feeTotal,
    required int feeUnknown,
    required int mealEstimate,
    required bool measured,
  }) = _RoutePlanImpl;

  factory RoutePlan.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoutePlan(
      kind: jsonSerialization['kind'] as String,
      stops: _in7lcnwt.Protocol().deserialize<List<_ii2p07ww.RouteStop>>(
        jsonSerialization['stops'],
      ),
      travelMin: jsonSerialization['travelMin'] as int,
      distanceM: jsonSerialization['distanceM'] as int,
      endMin: jsonSerialization['endMin'] as int,
      issues: jsonSerialization['issues'] as int,
      feeTotal: jsonSerialization['feeTotal'] as int,
      feeUnknown: jsonSerialization['feeUnknown'] as int,
      mealEstimate: jsonSerialization['mealEstimate'] as int,
      measured: _isc.BoolJsonExtension.fromJson(jsonSerialization['measured']),
    );
  }

  /// fast (least travel) | hours (fits opening hours) | meal (food at meal times)
  String kind;

  List<_ii2p07ww.RouteStop> stops;

  int travelMin;

  int distanceM;

  /// When the last stop is left, in minutes after midnight.
  int endMin;

  /// Stops that are likely closed on arrival.
  int issues;

  /// Sum of known admission fees in won (Korea only).
  int feeTotal;

  /// Stops whose admission fee is unknown.
  int feeUnknown;

  /// Estimated food spend per person in won (Korea only, 0 elsewhere).
  int mealEstimate;

  /// true when travel times come from Mapbox road data, false when estimated.
  bool measured;

  /// Returns a shallow copy of this [RoutePlan]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RoutePlan copyWith({
    String? kind,
    List<_ii2p07ww.RouteStop>? stops,
    int? travelMin,
    int? distanceM,
    int? endMin,
    int? issues,
    int? feeTotal,
    int? feeUnknown,
    int? mealEstimate,
    bool? measured,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoutePlan',
      'kind': kind,
      'stops': stops.toJson(valueToJson: (v) => v.toJson()),
      'travelMin': travelMin,
      'distanceM': distanceM,
      'endMin': endMin,
      'issues': issues,
      'feeTotal': feeTotal,
      'feeUnknown': feeUnknown,
      'mealEstimate': mealEstimate,
      'measured': measured,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoutePlan',
      'kind': kind,
      'stops': stops.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'travelMin': travelMin,
      'distanceM': distanceM,
      'endMin': endMin,
      'issues': issues,
      'feeTotal': feeTotal,
      'feeUnknown': feeUnknown,
      'mealEstimate': mealEstimate,
      'measured': measured,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _RoutePlanImpl extends RoutePlan {
  _RoutePlanImpl({
    required String kind,
    required List<_ii2p07ww.RouteStop> stops,
    required int travelMin,
    required int distanceM,
    required int endMin,
    required int issues,
    required int feeTotal,
    required int feeUnknown,
    required int mealEstimate,
    required bool measured,
  }) : super._(
         kind: kind,
         stops: stops,
         travelMin: travelMin,
         distanceM: distanceM,
         endMin: endMin,
         issues: issues,
         feeTotal: feeTotal,
         feeUnknown: feeUnknown,
         mealEstimate: mealEstimate,
         measured: measured,
       );

  /// Returns a shallow copy of this [RoutePlan]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RoutePlan copyWith({
    String? kind,
    List<_ii2p07ww.RouteStop>? stops,
    int? travelMin,
    int? distanceM,
    int? endMin,
    int? issues,
    int? feeTotal,
    int? feeUnknown,
    int? mealEstimate,
    bool? measured,
  }) {
    return RoutePlan(
      kind: kind ?? this.kind,
      stops: stops ?? this.stops.map((e0) => e0.copyWith()).toList(),
      travelMin: travelMin ?? this.travelMin,
      distanceM: distanceM ?? this.distanceM,
      endMin: endMin ?? this.endMin,
      issues: issues ?? this.issues,
      feeTotal: feeTotal ?? this.feeTotal,
      feeUnknown: feeUnknown ?? this.feeUnknown,
      mealEstimate: mealEstimate ?? this.mealEstimate,
      measured: measured ?? this.measured,
    );
  }
}
