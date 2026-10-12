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

/// A place to buy local specialties or souvenirs (markets, craft shops).
/// Comes from TourAPI shopping info, Kakao or OpenStreetMap, never from AI.
abstract class ShopHit
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ShopHit._({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.kind,
    this.items,
    this.hours,
    this.imageUrl,
    required this.source,
  });

  factory ShopHit({
    required String name,
    required String address,
    required double lat,
    required double lng,
    required String kind,
    String? items,
    String? hours,
    String? imageUrl,
    required String source,
  }) = _ShopHitImpl;

  factory ShopHit.fromJson(Map<String, dynamic> jsonSerialization) {
    return ShopHit(
      name: jsonSerialization['name'] as String,
      address: jsonSerialization['address'] as String,
      lat: (jsonSerialization['lat'] as num).toDouble(),
      lng: (jsonSerialization['lng'] as num).toDouble(),
      kind: jsonSerialization['kind'] as String,
      items: jsonSerialization['items'] as String?,
      hours: jsonSerialization['hours'] as String?,
      imageUrl: jsonSerialization['imageUrl'] as String?,
      source: jsonSerialization['source'] as String,
    );
  }

  String name;

  String address;

  double lat;

  double lng;

  /// market | craft | souvenir | specialty | mall | shop
  String kind;

  /// What it sells, from the official info (e.g. "건어물 / 수산물").
  String? items;

  String? hours;

  String? imageUrl;

  /// tour | kakao | osm
  String source;

  /// Returns a shallow copy of this [ShopHit]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ShopHit copyWith({
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? kind,
    String? items,
    String? hours,
    String? imageUrl,
    String? source,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ShopHit',
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'kind': kind,
      if (items != null) 'items': items,
      if (hours != null) 'hours': hours,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'source': source,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ShopHit',
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'kind': kind,
      if (items != null) 'items': items,
      if (hours != null) 'hours': hours,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'source': source,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ShopHitImpl extends ShopHit {
  _ShopHitImpl({
    required String name,
    required String address,
    required double lat,
    required double lng,
    required String kind,
    String? items,
    String? hours,
    String? imageUrl,
    required String source,
  }) : super._(
         name: name,
         address: address,
         lat: lat,
         lng: lng,
         kind: kind,
         items: items,
         hours: hours,
         imageUrl: imageUrl,
         source: source,
       );

  /// Returns a shallow copy of this [ShopHit]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ShopHit copyWith({
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? kind,
    Object? items = _Undefined,
    Object? hours = _Undefined,
    Object? imageUrl = _Undefined,
    String? source,
  }) {
    return ShopHit(
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      kind: kind ?? this.kind,
      items: items is String? ? items : this.items,
      hours: hours is String? ? hours : this.hours,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      source: source ?? this.source,
    );
  }
}
