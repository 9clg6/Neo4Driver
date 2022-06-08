class NotEnoughIdException implements Exception {
  late String cause;
  NotEnoughIdException({required this.cause});
}
