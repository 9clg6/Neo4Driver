/// Exception throw if the given ID is incorrect (ex. negative ID)
class InvalidIdException implements Exception {
  late String cause;
  InvalidIdException({required this.cause});
}
