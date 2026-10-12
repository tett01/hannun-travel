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
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:trippick_server/src/generated/places/location_hit.dart'
    as _i41cypjd;
import 'package:trippick_server/src/generated/places/place.dart' as _i8c2er40;
import 'package:trippick_server/src/generated/places/place_report.dart'
    as _iskcn2mu;
import 'package:trippick_server/src/generated/places/route_plan.dart'
    as _i37s88i3;
import 'package:trippick_server/src/generated/places/shop_hit.dart'
    as _iwxk0bej;
import 'package:trippick_server/src/generated/places/trip.dart' as _idvxes01;
import 'package:trippick_server/src/generated/places/user_review.dart'
    as _ipn410b6;
import 'places/collected_area.dart' as _iefsfaz0;
import 'places/location_hit.dart' as _icggq6kf;
import 'places/place.dart' as _ion0otjm;
import 'places/place_report.dart' as _i85w78xd;
import 'places/review_summary.dart' as _ii1d0owx;
import 'places/route_plan.dart' as _ijecgs00;
import 'places/route_stop.dart' as _iciv6ehk;
import 'places/shop_hit.dart' as _i4y0djlf;
import 'places/trip.dart' as _i3d89mdh;
import 'places/trip_day.dart' as _ivaukw60;
import 'places/user_review.dart' as _ipwgf7iv;
export 'places/collected_area.dart';
export 'places/location_hit.dart';
export 'places/place.dart';
export 'places/place_report.dart';
export 'places/review_summary.dart';
export 'places/route_plan.dart';
export 'places/route_stop.dart';
export 'places/shop_hit.dart';
export 'places/trip.dart';
export 'places/trip_day.dart';
export 'places/user_review.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'collected_area',
      dartName: 'CollectedArea',
      schema: 'public',
      module: 'trippick',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'lat',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'lng',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'collectedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'place',
      dartName: 'Place',
      schema: 'public',
      module: 'trippick',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'sourceId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'nameEn',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'category',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'subcategory',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'address',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'lat',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'lng',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'tel',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'imageUrl',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'images',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'List<String>?',
        ),
        _isp.ColumnDefinition(
          name: 'overview',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'facts',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'Map<String,String>?',
        ),
        _isp.ColumnDefinition(
          name: 'factsEn',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'Map<String,String>?',
        ),
        _isp.ColumnDefinition(
          name: 'highlightKo',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:ReviewSummary?',
        ),
        _isp.ColumnDefinition(
          name: 'highlightEn',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:ReviewSummary?',
        ),
        _isp.ColumnDefinition(
          name: 'reviewSummaryKo',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:ReviewSummary?',
        ),
        _isp.ColumnDefinition(
          name: 'reviewSummaryEn',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:ReviewSummary?',
        ),
        _isp.ColumnDefinition(
          name: 'reviewSummaryBasis',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'reviewCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'ratingAvg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'tags',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'List<String>?',
        ),
        _isp.ColumnDefinition(
          name: 'detailFetchedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'summarizedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'summaryVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'place_source_id_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sourceId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'place_report',
      dartName: 'PlaceReport',
      schema: 'public',
      module: 'trippick',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'placeId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'place_report_place_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'placeId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'trip',
      dartName: 'Trip',
      schema: 'public',
      module: 'trippick',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'deviceId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'area',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'days',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:TripDay>',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'trip_device_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'deviceId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'user_review',
      dartName: 'UserReview',
      schema: 'public',
      module: 'trippick',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'placeId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'author',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'rating',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'text',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'user_review_place_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'placeId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._isp.Protocol.targetTableDefinitions,
  ];

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
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iefsfaz0.CollectedArea) {
      return _iefsfaz0.CollectedArea.fromJson(data) as T;
    }
    if (t == _icggq6kf.LocationHit) {
      return _icggq6kf.LocationHit.fromJson(data) as T;
    }
    if (t == _ion0otjm.Place) {
      return _ion0otjm.Place.fromJson(data) as T;
    }
    if (t == _i85w78xd.PlaceReport) {
      return _i85w78xd.PlaceReport.fromJson(data) as T;
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
    if (t == _i4y0djlf.ShopHit) {
      return _i4y0djlf.ShopHit.fromJson(data) as T;
    }
    if (t == _i3d89mdh.Trip) {
      return _i3d89mdh.Trip.fromJson(data) as T;
    }
    if (t == _ivaukw60.TripDay) {
      return _ivaukw60.TripDay.fromJson(data) as T;
    }
    if (t == _ipwgf7iv.UserReview) {
      return _ipwgf7iv.UserReview.fromJson(data) as T;
    }
    if (t == _is.getType<_iefsfaz0.CollectedArea?>()) {
      return (data != null ? _iefsfaz0.CollectedArea.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_icggq6kf.LocationHit?>()) {
      return (data != null ? _icggq6kf.LocationHit.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ion0otjm.Place?>()) {
      return (data != null ? _ion0otjm.Place.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i85w78xd.PlaceReport?>()) {
      return (data != null ? _i85w78xd.PlaceReport.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ii1d0owx.ReviewSummary?>()) {
      return (data != null ? _ii1d0owx.ReviewSummary.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ijecgs00.RoutePlan?>()) {
      return (data != null ? _ijecgs00.RoutePlan.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iciv6ehk.RouteStop?>()) {
      return (data != null ? _iciv6ehk.RouteStop.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4y0djlf.ShopHit?>()) {
      return (data != null ? _i4y0djlf.ShopHit.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3d89mdh.Trip?>()) {
      return (data != null ? _i3d89mdh.Trip.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ivaukw60.TripDay?>()) {
      return (data != null ? _ivaukw60.TripDay.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ipwgf7iv.UserReview?>()) {
      return (data != null ? _ipwgf7iv.UserReview.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _is.getType<List<String>?>()) {
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
    if (t == _is.getType<Map<String, String>?>()) {
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
    if (t == List<_ivaukw60.TripDay>) {
      return (data as List)
              .map((e) => deserialize<_ivaukw60.TripDay>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_i8c2er40.Place>) {
      return (data as List).map((e) => deserialize<_i8c2er40.Place>(e)).toList()
          as T;
    }
    if (t == List<_i41cypjd.LocationHit>) {
      return (data as List)
              .map((e) => deserialize<_i41cypjd.LocationHit>(e))
              .toList()
          as T;
    }
    if (t == List<_iwxk0bej.ShopHit>) {
      return (data as List)
              .map((e) => deserialize<_iwxk0bej.ShopHit>(e))
              .toList()
          as T;
    }
    if (t == List<_iskcn2mu.PlaceReport>) {
      return (data as List)
              .map((e) => deserialize<_iskcn2mu.PlaceReport>(e))
              .toList()
          as T;
    }
    if (t == List<_ipn410b6.UserReview>) {
      return (data as List)
              .map((e) => deserialize<_ipn410b6.UserReview>(e))
              .toList()
          as T;
    }
    if (t == List<_i37s88i3.RoutePlan>) {
      return (data as List)
              .map((e) => deserialize<_i37s88i3.RoutePlan>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_idvxes01.Trip>) {
      return (data as List).map((e) => deserialize<_idvxes01.Trip>(e)).toList()
          as T;
    }
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iefsfaz0.CollectedArea => 'CollectedArea',
      _icggq6kf.LocationHit => 'LocationHit',
      _ion0otjm.Place => 'Place',
      _i85w78xd.PlaceReport => 'PlaceReport',
      _ii1d0owx.ReviewSummary => 'ReviewSummary',
      _ijecgs00.RoutePlan => 'RoutePlan',
      _iciv6ehk.RouteStop => 'RouteStop',
      _i4y0djlf.ShopHit => 'ShopHit',
      _i3d89mdh.Trip => 'Trip',
      _ivaukw60.TripDay => 'TripDay',
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
      case _iefsfaz0.CollectedArea():
        return 'CollectedArea';
      case _icggq6kf.LocationHit():
        return 'LocationHit';
      case _ion0otjm.Place():
        return 'Place';
      case _i85w78xd.PlaceReport():
        return 'PlaceReport';
      case _ii1d0owx.ReviewSummary():
        return 'ReviewSummary';
      case _ijecgs00.RoutePlan():
        return 'RoutePlan';
      case _iciv6ehk.RouteStop():
        return 'RouteStop';
      case _i4y0djlf.ShopHit():
        return 'ShopHit';
      case _i3d89mdh.Trip():
        return 'Trip';
      case _ivaukw60.TripDay():
        return 'TripDay';
      case _ipwgf7iv.UserReview():
        return 'UserReview';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CollectedArea') {
      return deserialize<_iefsfaz0.CollectedArea>(data['data']);
    }
    if (dataClassName == 'LocationHit') {
      return deserialize<_icggq6kf.LocationHit>(data['data']);
    }
    if (dataClassName == 'Place') {
      return deserialize<_ion0otjm.Place>(data['data']);
    }
    if (dataClassName == 'PlaceReport') {
      return deserialize<_i85w78xd.PlaceReport>(data['data']);
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
    if (dataClassName == 'ShopHit') {
      return deserialize<_i4y0djlf.ShopHit>(data['data']);
    }
    if (dataClassName == 'Trip') {
      return deserialize<_i3d89mdh.Trip>(data['data']);
    }
    if (dataClassName == 'TripDay') {
      return deserialize<_ivaukw60.TripDay>(data['data']);
    }
    if (dataClassName == 'UserReview') {
      return deserialize<_ipwgf7iv.UserReview>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iefsfaz0.CollectedArea:
        return _iefsfaz0.CollectedArea.t;
      case _ion0otjm.Place:
        return _ion0otjm.Place.t;
      case _i85w78xd.PlaceReport:
        return _i85w78xd.PlaceReport.t;
      case _i3d89mdh.Trip:
        return _i3d89mdh.Trip.t;
      case _ipwgf7iv.UserReview:
        return _ipwgf7iv.UserReview.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
    try {
      return _isp.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
