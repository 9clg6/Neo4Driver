/// Exception throw if try to create param-less node
class NoParamNodeException implements Exception {
  late String cause;
  NoParamNodeException({required this.cause});
}
