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
import '../places/place_endpoint.dart' as _iyw3o9dp;
import '../places/review_endpoint.dart' as _iptyoesq;

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
      'review': _iptyoesq.ReviewEndpoint()
        ..initialize(
          server,
          'review',
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
  }
}
