import 'package:substitute/substitute.dart';

class VersionedSubstitute extends Substitute {
  static int? currentVersion;

  final int? minVersion;
  final int? maxVersion;

  VersionedSubstitute.fromSedExpr(String expr,
      {this.minVersion, this.maxVersion})
      : super.fromSedExpr(expr);

  @override
  String apply(String input) {
    if (currentVersion != null) {
      if (minVersion != null && currentVersion! < minVersion!) {
        return input;
      }
      if (maxVersion != null && currentVersion! > maxVersion!) {
        return input;
      }
    }
    return super.apply(input);
  }
}
