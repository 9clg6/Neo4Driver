import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/models/request_data.dart';
import 'package:http_interceptor/models/response_data.dart';

class CustomInterceptor implements InterceptorContract {
  final Map<String, String> headersModifier;

  CustomInterceptor(this.headersModifier);

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async => data;

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    return data..headers?.addAll(headersModifier);
  }
}
