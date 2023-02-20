import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:neo4driver/src/interceptor/custom_interceptor.dart';

import '../enum/http_method.dart';

/// Cypher query executor
class CypherExecutor {
  late Client httpClient = Client();
  String? databaseAddress;
  String? databaseName;
  String? token;

  /// Constructs cypher executor with [databaseAddress]
  CypherExecutor({required this.databaseAddress});

  /// Constructs cypher executor with [httpClient]
  CypherExecutor.withHttpClient({required this.httpClient});

  /// Constructs cypher executor with credentials [username], [password] and [databaseAddress]
  /// Credentials are not stored, they are used to build base 64 encoded token (utf8)
  CypherExecutor.withAuthorization({
    required String username,
    required String password,
    required this.databaseAddress,
    required this.databaseName,
    CustomInterceptor? customInterceptor,
  }) {
    token = base64Encode(utf8.encode("$username:$password"));
    if (customInterceptor != null) {
      httpClient = InterceptedClient.build(interceptors: [customInterceptor]);
    }
  }

  /// Execute given [query] with given http [method]
  /// GET is not implemented
  Future<Response> executeQuery({required HTTPMethod method, required String query}) async {
    late Future<Response> response;

    switch (method) {
      case HTTPMethod.get:
        if (token != null) {
          //TODO
        } else {
          //TODO
        }
        break;
      case HTTPMethod.post:
        if (token != null) {
          response = _executePostRequestWithAuthorization(query);
        } else {
          response = _executePostRequest(query);
        }
        break;
    }
    return response;
  }

  /// Execute and commits given [query] with authorization header ([token])
  Future<Response> _executePostRequestWithAuthorization(String query) {
    return httpClient.post(
      Uri.parse('${databaseAddress}db/$databaseName/tx/commit'),
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
        HttpHeaders.authorizationHeader: token!,
        'content-Type': 'application/json',
      },
    );
  }

  /// Execute and commits given [query]
  Future<Response> _executePostRequest(String query) {
    return httpClient.post(
      Uri.parse('${databaseAddress}db/$databaseName/tx/commit'),
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
      encoding: const Utf8Codec(),
    );
  }
}
