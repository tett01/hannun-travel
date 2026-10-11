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
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:trippick_client/src/protocol/places/location_hit.dart'
    as _iojwpf7q;
import 'package:trippick_client/src/protocol/places/place.dart' as _itawvtbq;
import 'package:trippick_client/src/protocol/places/user_review.dart'
    as _iqsxj9y5;
import 'protocol.dart' as _il2as5qe;

/// Accessed from the app as `client.place`.
/// {@category Endpoint}
class EndpointPlace extends _isc.EndpointRef {
  EndpointPlace(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'place';

  /// Places within the search radius of ([lat], [lng]), nearest first.
  /// The first request for a new area collects its places first.
  /// Korea uses TourAPI/Kakao; elsewhere OpenStreetMap + Wikipedia.
  _ida.Future<List<_itawvtbq.Place>> nearby(
    double lat,
    double lng,
  ) => caller.callServerEndpoint<List<_itawvtbq.Place>>(
    'place',
    'nearby',
    {
      'lat': lat,
      'lng': lng,
    },
  );

  /// Neighborhood name such as "해운대구 우동" ('' if unknown).
  _ida.Future<String> regionName(
    double lat,
    double lng,
    String language,
  ) => caller.callServerEndpoint<String>(
    'place',
    'regionName',
    {
      'lat': lat,
      'lng': lng,
      'language': language,
    },
  );

  /// Places or addresses matching [query], for picking an area to explore
  /// (e.g. "near my hotel"). Korea comes from Kakao, the rest of the world
  /// from OpenStreetMap. A Korean query lists Kakao first; a query in other
  /// letters lists OpenStreetMap first, since Kakao matches romanized names
  /// poorly ("Gyeongbokgung" finds restaurants named after the palace).
  _ida.Future<List<_iojwpf7q.LocationHit>> searchLocation(
    String query,
    String language,
  ) => caller.callServerEndpoint<List<_iojwpf7q.LocationHit>>(
    'place',
    'searchLocation',
    {
      'query': query,
      'language': language,
    },
  );
}

/// Accessed from the app as `client.review`.
/// {@category Endpoint}
class EndpointReview extends _isc.EndpointRef {
  EndpointReview(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'review';

  _ida.Future<List<_iqsxj9y5.UserReview>> list(int placeId) =>
      caller.callServerEndpoint<List<_iqsxj9y5.UserReview>>(
        'review',
        'list',
        {'placeId': placeId},
      );

  /// Saves a review, updates the rating, and refreshes the AI review summary.
  /// Returns the updated place.
  _ida.Future<_itawvtbq.Place> add(
    int placeId,
    String author,
    int rating,
    String text,
  ) => caller.callServerEndpoint<_itawvtbq.Place>(
    'review',
    'add',
    {
      'placeId': placeId,
      'author': author,
      'rating': rating,
      'text': text,
    },
  );
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    place = EndpointPlace(this);
    review = EndpointReview(this);
  }

  late final EndpointPlace place;

  late final EndpointReview review;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'place': place,
    'review': review,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {};
}
