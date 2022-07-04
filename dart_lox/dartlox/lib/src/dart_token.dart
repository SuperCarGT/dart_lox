import 'package:dartlox/src/dart_token_type.dart';

class Token {
  final TokenType type;
  final String lexeme;
  final dynamic literal;
  final int line;

  Token({required this.type, required this.lexeme, required this.line,required this.literal});
  @override
  String toString() {
    return '$type  $lexeme  $literal';
  }
}
