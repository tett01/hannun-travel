/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:trippick_client/src/protocol/places/location_hit.dart'
    as _iojwpf7q;
import 'package:trippick_client/src/protocol/places/place.dart' as _itawvtbq;
import 'package:trippick_client/src/protocol/places/route_plan.dart'
    as _i0nbmmlc;
import 'package:trippick_client/src/protocol/places/user_review.dart'
    as _iqsxj9y5;
import 'places/location_hit.dart' as _icggq6kf;
import 'places/place.dart' as _ion0otjm;
import 'places/review_summary.dart' as _ii1d0owx;
import 'places/route_plan.dart' as _ijecgs00;
import 'places/route_stop.dart' as _iciv6ehk;
import 'places/user_review.dart' as _ipwgf7iv;
export 'places/location_hit.dart';
export 'places/place.dart';
export 'places/review_summary.dart';
export 'places/route_plan.dart';
export 'places/route_stop.dart';
export 'places/user_review.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _icggq6kf.LocationHit) {
      return _icggq6kf.LocationHit.fromJson(data) as T;
    }
    if (t == _ion0otjm.Place) {
      return _ion0otjm.Place.fromJson(data) as T;
    }
    if (t == _ii1d0owx.ReviewSummary) {
      return _ii1d0owx.ReviewSummary.fromJson(data) as T;
    }
    if (t == _ijecgs00.RoutePlan) {
      return _ijecgs00.RoutePlan.fromJson(data) as T;
    }
    if (t == _iciv6ehk.RouteStop) {
      return _iciv6ehk.RouteStop.fromJson(data) as T;
    }
    if (t == _ipwgf7iv.UserReview) {
      return _ipwgf7iv.UserReview.fromJson(data) as T;
    }
    if (t == _isc.getType<_icggq6kf.LocationHit?>()) {
      return (data != null ? _icggq6kf.LocationHit.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ion0otjm.Place?>()) {
      return (data != null ? _ion0otjm.Place.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ii1d0owx.ReviewSummary?>()) {
      return (data != null ? _ii1d0owx.ReviewSummary.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ijecgs00.RoutePlan?>()) {
      return (data != null ? _ijecgs00.RoutePlan.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iciv6ehk.RouteStop?>()) {
      return (data != null ? _iciv6ehk.RouteStop.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ipwgf7iv.UserReview?>()) {
      return (data != null ? _ipwgf7iv.UserReview.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _isc.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _isc.getType<Map<String, String>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<String>(v)),
                )
              : null)
          as T;
    }
    if (t == List<_iciv6ehk.RouteStop>) {
      return (data as List)
              .map((e) => deserialize<_iciv6ehk.RouteStop>(e))
              .toList()
          as T;
    }
    if (t == List<_itawvtbq.Place>) {
      return (data as List).map((e) => deserialize<_itawvtbq.Place>(e)).toList()
          as T;
    }
    if (t == List<_iojwpf7q.LocationHit>) {
      return (data as List)
              .map((e) => deserialize<_iojwpf7q.LocationHit>(e))
              .toList()
          as T;
    }
    if (t == List<_iqsxj9y5.UserReview>) {
      return (data as List)
              .map((e) => deserialize<_iqsxj9y5.UserReview>(e))
              .toList()
          as T;
    }
    if (t == List<_i0nbmmlc.RoutePlan>) {
      return (data as List)
              .map((e) => deserialize<_i0nbmmlc.RoutePlan>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _icggq6kf.LocationHit => 'LocationHit',
      _ion0otjm.Place => 'Place',
      _ii1d0owx.ReviewSummary => 'ReviewSummary',
      _ijecgs00.RoutePlan => 'RoutePlan',
      _iciv6ehk.RouteStop => 'RouteStop',
      _ipwgf7iv.UserReview => 'UserReview',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('trippick.', '');
    }

    switch (data) {
      case _icggq6kf.LocationHit():
        return 'LocationHit';
      case _ion0otjm.Place():
        return 'Place';
      case _ii1d0owx.ReviewSummary():
        return 'ReviewSummary';
      case _ijecgs00.RoutePlan():
        return 'RoutePlan';
      case _iciv6ehk.RouteStop():
        return 'RouteStop';
      case _ipwgf7iv.UserReview():
        return 'UserReview';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'LocationHit') {
      return deserialize<_icggq6kf.LocationHit>(data['data']);
    }
    if (dataClassName == 'Place') {
      return deserialize<_ion0otjm.Place>(data['data']);
    }
    if (dataClassName == 'ReviewSummary') {
      return deserialize<_ii1d0owx.ReviewSummary>(data['data']);
    }
    if (dataClassName == 'RoutePlan') {
      return deserialize<_ijecgs00.RoutePlan>(data['data']);
    }
    if (dataClassName == 'RouteStop') {
      return deserialize<_iciv6ehk.RouteStop>(data['data']);
    }
    if (dataClassName == 'UserReview') {
      return deserialize<_ipwgf7iv.UserReview>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  @override
  String getModuleName() => 'trippick';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
