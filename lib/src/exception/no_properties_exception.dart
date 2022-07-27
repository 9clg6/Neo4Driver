/// Exception throw if no properties are given in parameters
class NoPropertiesException implements Exception {
  late String cause;
  NoPropertiesException({required this.cause});
}