import 'dart:convert';
import 'package:http/http.dart';
import 'package:neo4dart/src/enum/http_method.dart';
import 'package:neo4dart/src/neo4dart/neo_client.dart';
import 'dart:io';

class CypherExecutor {
  final NeoClient _neoClient;

  CypherExecutor(this._neoClient);

  Future<Response> executeQuery({required HTTPMethod method, required String query}) async {
    late Future<Response> response;

    switch (method) {
      case HTTPMethod.get:
        if (_neoClient.token != null) {
          //TODO
        } else {
          //TODO
        }
        break;
      case HTTPMethod.post:
        if (_neoClient.token != null) {
          response = _executePostRequestWithAuthorization(query);
        } else {
          response = _executePostRequest(query);
        }
        break;
    }
    return response;
  }

  Future<Response> _executePostRequestWithAuthorization(String query) {
    return _neoClient.httpClient.post(
      Uri.parse('${_neoClient.databaseAddress}db/neo4j/tx/commit'),
      body: const JsonEncoder().convert(
        {
          "statements": [
            {
              "statement": query,
            },
          ]
        },
      ),
      headers: {
        HttpHeaders.authorizationHeader: _neoClient.token!,
        'content-Type': 'application/json',
      },
    );
  }
  Future<Response> _executePostRequest(String query) {
    return _neoClient.httpClient.post(
      Uri.parse('${_neoClient.databaseAddress}db/neo4j/tx/commit'),
      body: const JsonEncoder().convert(
        {
          "statements": [
            {
              "statement": query,
            },
          ]
        },
      ),
      headers: {
        'content-Type': 'application/json',
      },
    );
  }
}
