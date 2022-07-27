/// Exception throw if there is not enough ID given in paremeters
class NotEnoughIdException implements Exception {
  late String cause;
  NotEnoughIdException({required this.cause});
}
