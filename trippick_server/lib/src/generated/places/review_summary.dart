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

/// Three-line AI summary.
/// For official info: good = highlights, bad = good to know, tip = tip.
/// For user reviews: good = pros, bad = cons, tip = tip.
abstract class ReviewSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ReviewSummary._({
    required this.good,
    required this.bad,
    required this.tip,
  });

  factory ReviewSummary({
    required String good,
    required String bad,
    required String tip,
  }) = _ReviewSummaryImpl;

  factory ReviewSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReviewSummary(
      good: jsonSerialization['good'] as String,
      bad: jsonSerialization['bad'] as String,
      tip: jsonSerialization['tip'] as String,
    );
  }

  String good;

  String bad;

  String tip;

  /// Returns a shallow copy of this [ReviewSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ReviewSummary copyWith({
    String? good,
    String? bad,
    String? tip,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReviewSummary',
      'good': good,
      'bad': bad,
      'tip': tip,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReviewSummary',
      'good': good,
      'bad': bad,
      'tip': tip,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ReviewSummaryImpl extends ReviewSummary {
  _ReviewSummaryImpl({
    required String good,
    required String bad,
    required String tip,
  }) : super._(
         good: good,
         bad: bad,
         tip: tip,
       );

  /// Returns a shallow copy of this [ReviewSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ReviewSummary copyWith({
    String? good,
    String? bad,
    String? tip,
  }) {
    return ReviewSummary(
      good: good ?? this.good,
      bad: bad ?? this.bad,
      tip: tip ?? this.tip,
    );
  }
}
