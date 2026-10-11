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

/// A place or address found by the location search.
abstract class LocationHit
    implements _is.SerializableModel, _is.ProtocolSerialization {
  LocationHit._({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory LocationHit({
    required String name,
    required String address,
    required double lat,
    required double lng,
  }) = _LocationHitImpl;

  factory LocationHit.fromJson(Map<String, dynamic> jsonSerialization) {
    return LocationHit(
      name: jsonSerialization['name'] as String,
      address: jsonSerialization['address'] as String,
      lat: (jsonSerialization['lat'] as num).toDouble(),
      lng: (jsonSerialization['lng'] as num).toDouble(),
    );
  }

  String name;

  String address;

  double lat;

  double lng;

  /// Returns a shallow copy of this [LocationHit]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LocationHit copyWith({
    String? name,
    String? address,
    double? lat,
    double? lng,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LocationHit',
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LocationHit',
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _LocationHitImpl extends LocationHit {
  _LocationHitImpl({
    required String name,
    required String address,
    required double lat,
    required double lng,
  }) : super._(
         name: name,
         address: address,
         lat: lat,
         lng: lng,
       );

  /// Returns a shallow copy of this [LocationHit]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LocationHit copyWith({
    String? name,
    String? address,
    double? lat,
    double? lng,
  }) {
    return LocationHit(
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
