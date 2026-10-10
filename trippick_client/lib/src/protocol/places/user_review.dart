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

/// A review written in the app.
abstract class UserReview
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UserReview._({
    this.id,
    required this.placeId,
    required this.author,
    required this.rating,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserReview({
    int? id,
    required int placeId,
    required String author,
    required int rating,
    required String text,
    DateTime? createdAt,
  }) = _UserReviewImpl;

  factory UserReview.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserReview(
      id: jsonSerialization['id'] as int?,
      placeId: jsonSerialization['placeId'] as int,
      author: jsonSerialization['author'] as String,
      rating: jsonSerialization['rating'] as int,
      text: jsonSerialization['text'] as String,
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

  String author;

  /// 1 to 5
  int rating;

  String text;

  DateTime createdAt;

  /// Returns a shallow copy of this [UserReview]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserReview copyWith({
    int? id,
    int? placeId,
    String? author,
    int? rating,
    String? text,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserReview',
      if (id != null) 'id': id,
      'placeId': placeId,
      'author': author,
      'rating': rating,
      'text': text,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserReview',
      if (id != null) 'id': id,
      'placeId': placeId,
      'author': author,
      'rating': rating,
      'text': text,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserReviewImpl extends UserReview {
  _UserReviewImpl({
    int? id,
    required int placeId,
    required String author,
    required int rating,
    required String text,
    DateTime? createdAt,
  }) : super._(
         id: id,
         placeId: placeId,
         author: author,
         rating: rating,
         text: text,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [UserReview]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserReview copyWith({
    Object? id = _Undefined,
    int? placeId,
    String? author,
    int? rating,
    String? text,
    DateTime? createdAt,
  }) {
    return UserReview(
      id: id is int? ? id : this.id,
      placeId: placeId ?? this.placeId,
      author: author ?? this.author,
      rating: rating ?? this.rating,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
