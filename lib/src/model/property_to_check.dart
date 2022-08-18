/// Property to check when findAllNodesByProperties is called
class PropertyToCheck {
  String key;
  dynamic value;
  String comparisonOperator;

  /// Constructs property to check with [key] - [value] and [comparisonOperator] (>,<,=,!=)
  PropertyToCheck({
    required this.key,
    required this.comparisonOperator,
    required this.value,
  });

}
