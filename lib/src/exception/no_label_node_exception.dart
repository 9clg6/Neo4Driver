/// Exceptions throw if try to create label-less node
class NoLabelNodeException implements Exception {
  late String cause;
  NoLabelNodeException({required this.cause});
}