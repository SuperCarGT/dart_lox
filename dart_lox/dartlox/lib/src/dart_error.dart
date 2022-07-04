import 'package:dartlox/src/dart_token.dart';

class ParserError implements Exception {
  final String message;

  ParserError(this.message);

  @override
  String toString() {
    String message = this.message;
    // if (message == null) return "Exception";
    return "Exception: $message";
  }
}

class RuntimeError implements Exception {
  final Token token;
  final String message;
  RuntimeError(this.token, this.message);

  @override
  String toString() {
    return "Exception: $message";
  }
}
