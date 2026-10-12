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
import 'package:trippick_client/src/protocol/places/place_report.dart'
    as _ia8ye04g;
import 'package:trippick_client/src/protocol/places/route_plan.dart'
    as _i0nbmmlc;
import 'package:trippick_client/src/protocol/places/shop_hit.dart' as _ifeirymj;
import 'package:trippick_client/src/protocol/places/trip.dart' as _igng1c0u;
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

  /// Stations near ([lat], [lng]) for "near a station" filters, cached per
  /// area since stations rarely move. Empty when unknown.
  _ida.Future<List<_iojwpf7q.LocationHit>> stations(
    double lat,
    double lng,
  ) => caller.callServerEndpoint<List<_iojwpf7q.LocationHit>>(
    'place',
    'stations',
    {
      'lat': lat,
      'lng': lng,
    },
  );

  /// Where to buy local specialties and souvenirs near ([lat], [lng]):
  /// markets, craft shops and specialty stores first, nearest first within
  /// each kind. Korea: TourAPI shopping info + Kakao; elsewhere OpenStreetMap.
  _ida.Future<List<_ifeirymj.ShopHit>> souvenirs(
    double lat,
    double lng,
  ) => caller.callServerEndpoint<List<_ifeirymj.ShopHit>>(
    'place',
    'souvenirs',
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

/// Accessed from the app as `client.report`.
/// {@category Endpoint}
class EndpointReport extends _isc.EndpointRef {
  EndpointReport(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'report';

  /// Saves a report that [placeId] differs from the shown info and returns
  /// the place's recent reports.
  _ida.Future<List<_ia8ye04g.PlaceReport>> add(
    int placeId,
    String kind,
    String note,
  ) => caller.callServerEndpoint<List<_ia8ye04g.PlaceReport>>(
    'report',
    'add',
    {
      'placeId': placeId,
      'kind': kind,
      'note': note,
    },
  );

  /// Reports for [placeId] from the last [recent] days, newest first.
  _ida.Future<List<_ia8ye04g.PlaceReport>> list(int placeId) =>
      caller.callServerEndpoint<List<_ia8ye04g.PlaceReport>>(
        'report',
        'list',
        {'placeId': placeId},
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

/// Accessed from the app as `client.route`.
/// {@category Endpoint}
class EndpointRoute extends _isc.EndpointRef {
  EndpointRoute(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'route';

  /// Different visiting orders for [placeIds], starting at ([startLat],
  /// [startLng]) at [startMin] (minutes after midnight) on [weekday]
  /// (1 = Monday). [mode] is driving | walking | transit.
  /// Travel times come from Mapbox when a token is set, else are estimated.
  _ida.Future<List<_i0nbmmlc.RoutePlan>> plan(
    List<int> placeIds,
    String mode,
    double startLat,
    double startLng,
    int startMin,
    int weekday,
  ) => caller.callServerEndpoint<List<_i0nbmmlc.RoutePlan>>(
    'route',
    'plan',
    {
      'placeIds': placeIds,
      'mode': mode,
      'startLat': startLat,
      'startLng': startLng,
      'startMin': startMin,
      'weekday': weekday,
    },
  );
}

/// Accessed from the app as `client.trip`. Trips belong to the random id
/// the app keeps on the device, since there is no sign-in yet.
/// {@category Endpoint}
class EndpointTrip extends _isc.EndpointRef {
  EndpointTrip(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'trip';

  /// Saves [trip] for [deviceId] and returns it with its id.
  _ida.Future<_igng1c0u.Trip> save(
    String deviceId,
    _igng1c0u.Trip trip,
  ) => caller.callServerEndpoint<_igng1c0u.Trip>(
    'trip',
    'save',
    {
      'deviceId': deviceId,
      'trip': trip,
    },
  );

  /// Trips saved on [deviceId], newest first.
  _ida.Future<List<_igng1c0u.Trip>> list(String deviceId) =>
      caller.callServerEndpoint<List<_igng1c0u.Trip>>(
        'trip',
        'list',
        {'deviceId': deviceId},
      );

  /// Deletes trip [id] if it belongs to [deviceId].
  _ida.Future<bool> delete(
    String deviceId,
    int id,
  ) => caller.callServerEndpoint<bool>(
    'trip',
    'delete',
    {
      'deviceId': deviceId,
      'id': id,
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
    report = EndpointReport(this);
    review = EndpointReview(this);
    route = EndpointRoute(this);
    trip = EndpointTrip(this);
  }

  late final EndpointPlace place;

  late final EndpointReport report;

  late final EndpointReview review;

  late final EndpointRoute route;

  late final EndpointTrip trip;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'place': place,
    'report': report,
    'review': review,
    'route': route,
    'trip': trip,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {};
}
