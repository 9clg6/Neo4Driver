import 'dart:convert';
import 'package:http/http.dart';
import 'package:neo4dart/src/enum/http_method.dart';
import 'dart:io';

class CypherExecutor {
  late Client httpClient = Client();
  String? databaseAddress;
  String? token;

  CypherExecutor({required this.databaseAddress});

  CypherExecutor.withHttpClient({required this.httpClient});

  CypherExecutor.withAuthorization(String username, String password, String databaseAddress){
    token = base64Encode(utf8.encode("$username:$password"));
  }

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

  Future<Response> _executePostRequestWithAuthorization(String query) {
    return httpClient.post(
      Uri.parse('${databaseAddress}db/neo4j/tx/commit'),
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
  Future<Response> _executePostRequest(String query) {
    return httpClient.post(
      Uri.parse('${databaseAddress}db/neo4j/tx/commit'),
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
