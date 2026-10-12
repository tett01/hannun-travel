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
import 'package:trippick_server/src/generated/places/trip.dart' as _idvxes01;
import '../places/place_endpoint.dart' as _iyw3o9dp;
import '../places/report_endpoint.dart' as _iddiujvh;
import '../places/review_endpoint.dart' as _iptyoesq;
import '../places/route_endpoint.dart' as _idzkey6u;
import '../places/trip_endpoint.dart' as _ihm8szw3;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'place': _iyw3o9dp.PlaceEndpoint()
        ..initialize(
          server,
          'place',
          null,
        ),
      'report': _iddiujvh.ReportEndpoint()
        ..initialize(
          server,
          'report',
          null,
        ),
      'review': _iptyoesq.ReviewEndpoint()
        ..initialize(
          server,
          'review',
          null,
        ),
      'route': _idzkey6u.RouteEndpoint()
        ..initialize(
          server,
          'route',
          null,
        ),
      'trip': _ihm8szw3.TripEndpoint()
        ..initialize(
          server,
          'trip',
          null,
        ),
    };
    connectors['place'] = _is.EndpointConnector(
      name: 'place',
      endpoint: endpoints['place']!,
      methodConnectors: {
        'nearby': _is.MethodConnector(
          name: 'nearby',
          params: {
            'lat': _is.ParameterDescription(
              name: 'lat',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'lng': _is.ParameterDescription(
              name: 'lng',
              type: _is.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['place'] as _iyw3o9dp.PlaceEndpoint).nearby(
                session,
                params['lat'],
                params['lng'],
              ),
        ),
        'stations': _is.MethodConnector(
          name: 'stations',
          params: {
            'lat': _is.ParameterDescription(
              name: 'lat',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'lng': _is.ParameterDescription(
              name: 'lng',
              type: _is.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['place'] as _iyw3o9dp.PlaceEndpoint).stations(
                    session,
                    params['lat'],
                    params['lng'],
                  ),
        ),
        'souvenirs': _is.MethodConnector(
          name: 'souvenirs',
          params: {
            'lat': _is.ParameterDescription(
              name: 'lat',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'lng': _is.ParameterDescription(
              name: 'lng',
              type: _is.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['place'] as _iyw3o9dp.PlaceEndpoint).souvenirs(
                    session,
                    params['lat'],
                    params['lng'],
                  ),
        ),
        'regionName': _is.MethodConnector(
          name: 'regionName',
          params: {
            'lat': _is.ParameterDescription(
              name: 'lat',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'lng': _is.ParameterDescription(
              name: 'lng',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'language': _is.ParameterDescription(
              name: 'language',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['place'] as _iyw3o9dp.PlaceEndpoint).regionName(
                    session,
                    params['lat'],
                    params['lng'],
                    params['language'],
                  ),
        ),
        'searchLocation': _is.MethodConnector(
          name: 'searchLocation',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'language': _is.ParameterDescription(
              name: 'language',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['place'] as _iyw3o9dp.PlaceEndpoint)
                  .searchLocation(
                    session,
                    params['query'],
                    params['language'],
                  ),
        ),
      },
    );
    connectors['report'] = _is.EndpointConnector(
      name: 'report',
      endpoint: endpoints['report']!,
      methodConnectors: {
        'add': _is.MethodConnector(
          name: 'add',
          params: {
            'placeId': _is.ParameterDescription(
              name: 'placeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'kind': _is.ParameterDescription(
              name: 'kind',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'note': _is.ParameterDescription(
              name: 'note',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['report'] as _iddiujvh.ReportEndpoint).add(
                session,
                params['placeId'],
                params['kind'],
                params['note'],
              ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'placeId': _is.ParameterDescription(
              name: 'placeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['report'] as _iddiujvh.ReportEndpoint).list(
                session,
                params['placeId'],
              ),
        ),
      },
    );
    connectors['review'] = _is.EndpointConnector(
      name: 'review',
      endpoint: endpoints['review']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'placeId': _is.ParameterDescription(
              name: 'placeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['review'] as _iptyoesq.ReviewEndpoint).list(
                session,
                params['placeId'],
              ),
        ),
        'add': _is.MethodConnector(
          name: 'add',
          params: {
            'placeId': _is.ParameterDescription(
              name: 'placeId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'author': _is.ParameterDescription(
              name: 'author',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'rating': _is.ParameterDescription(
              name: 'rating',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'text': _is.ParameterDescription(
              name: 'text',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['review'] as _iptyoesq.ReviewEndpoint).add(
                session,
                params['placeId'],
                params['author'],
                params['rating'],
                params['text'],
              ),
        ),
      },
    );
    connectors['route'] = _is.EndpointConnector(
      name: 'route',
      endpoint: endpoints['route']!,
      methodConnectors: {
        'plan': _is.MethodConnector(
          name: 'plan',
          params: {
            'placeIds': _is.ParameterDescription(
              name: 'placeIds',
              type: _is.getType<List<int>>(),
              nullable: false,
            ),
            'mode': _is.ParameterDescription(
              name: 'mode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'startLat': _is.ParameterDescription(
              name: 'startLat',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'startLng': _is.ParameterDescription(
              name: 'startLng',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'startMin': _is.ParameterDescription(
              name: 'startMin',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'weekday': _is.ParameterDescription(
              name: 'weekday',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['route'] as _idzkey6u.RouteEndpoint).plan(
                session,
                params['placeIds'],
                params['mode'],
                params['startLat'],
                params['startLng'],
                params['startMin'],
                params['weekday'],
              ),
        ),
      },
    );
    connectors['trip'] = _is.EndpointConnector(
      name: 'trip',
      endpoint: endpoints['trip']!,
      methodConnectors: {
        'save': _is.MethodConnector(
          name: 'save',
          params: {
            'deviceId': _is.ParameterDescription(
              name: 'deviceId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'trip': _is.ParameterDescription(
              name: 'trip',
              type: _is.getType<_idvxes01.Trip>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['trip'] as _ihm8szw3.TripEndpoint).save(
                session,
                params['deviceId'],
                params['trip'],
              ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'deviceId': _is.ParameterDescription(
              name: 'deviceId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'trip': _is.ParameterDescription(
              name: 'trip',
              type: _is.getType<_idvxes01.Trip>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['trip'] as _ihm8szw3.TripEndpoint).update(
                session,
                params['deviceId'],
                params['trip'],
              ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'deviceId': _is.ParameterDescription(
              name: 'deviceId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['trip'] as _ihm8szw3.TripEndpoint).list(
                session,
                params['deviceId'],
              ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'deviceId': _is.ParameterDescription(
              name: 'deviceId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['trip'] as _ihm8szw3.TripEndpoint).delete(
                session,
                params['deviceId'],
                params['id'],
              ),
        ),
      },
    );
  }
}
