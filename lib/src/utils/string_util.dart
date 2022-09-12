/// Util used to manipulate string
class StringUtil {
  /// Transform list of string into a simple string (concatenation with , )
  static String buildLabelString(List<String> labels) {
    String labelsString = "";

    if (labels.length > 1) {
      for (int i = 0; i < labels.length; i++) {
        if (labels.elementAt(i) != labels.last) {
          labelsString += "${labels.elementAt(i)},";
        } else {
          labelsString += labels.elementAt(i);
        }
      }
    } else if (labels.length == 1) {
      labelsString = labels.first;
    } else {
      labelsString = "";
    }
    return labelsString;
  }
}
