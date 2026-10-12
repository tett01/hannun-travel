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

/// A traveler's report that a place differs from the info shown in the app,
/// e.g. it has closed or its hours changed.
abstract class PlaceReport
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PlaceReport._({
    this.id,
    required this.placeId,
    required this.kind,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PlaceReport({
    int? id,
    required int placeId,
    required String kind,
    String? note,
    DateTime? createdAt,
  }) = _PlaceReportImpl;

  factory PlaceReport.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlaceReport(
      id: jsonSerialization['id'] as int?,
      placeId: jsonSerialization['placeId'] as int,
      kind: jsonSerialization['kind'] as String,
      note: jsonSerialization['note'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int placeId;

  /// closed_forever | hours | break_time | closed_day | other
  String kind;

  String? note;

  DateTime createdAt;

  /// Returns a shallow copy of this [PlaceReport]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PlaceReport copyWith({
    int? id,
    int? placeId,
    String? kind,
    String? note,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlaceReport',
      if (id != null) 'id': id,
      'placeId': placeId,
      'kind': kind,
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlaceReport',
      if (id != null) 'id': id,
      'placeId': placeId,
      'kind': kind,
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlaceReportImpl extends PlaceReport {
  _PlaceReportImpl({
    int? id,
    required int placeId,
    required String kind,
    String? note,
    DateTime? createdAt,
  }) : super._(
         id: id,
         placeId: placeId,
         kind: kind,
         note: note,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PlaceReport]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PlaceReport copyWith({
    Object? id = _Undefined,
    int? placeId,
    String? kind,
    Object? note = _Undefined,
    DateTime? createdAt,
  }) {
    return PlaceReport(
      id: id is int? ? id : this.id,
      placeId: placeId ?? this.placeId,
      kind: kind ?? this.kind,
      note: note is String? ? note : this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
