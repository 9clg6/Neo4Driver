/// Exceptions throw if try to create label-less node
class NoLabelNode implements Exception {
  late String cause;
  NoLabelNode({required this.cause});
}