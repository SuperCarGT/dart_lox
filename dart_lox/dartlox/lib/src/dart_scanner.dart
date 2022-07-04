import 'package:dartlox/src/dart_token.dart';

import 'dart_lox.dart';
import 'dart_token_type.dart';

class Scanner {
  late final String _source;
  final List<Token> _tokens = <Token>[];
  int _start = 0;
  int _current = 0;
  int _line = 1;

  final Map<String, TokenType> _keywords = {
    '&&': TokenType.AND,
    'class': TokenType.CLASS,
    'else': TokenType.ELSE,
    'false': TokenType.FALSE,
    'fun': TokenType.FUN,
    'if': TokenType.IF,
    'nil': TokenType.NIL,
    'or': TokenType.OR,
    'print': TokenType.PRINT,
    'return': TokenType.RETURN,
    'super': TokenType.SUPER,
    'this': TokenType.THIS,
    'true': TokenType.TRUE,
    'var': TokenType.VAR,
    'while': TokenType.WHILE,
  };

  Scanner(String source) {
    _source = source;
  }

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _start = _current;
      _scanToken();
    }
    _tokens.add(
        Token(type: TokenType.EOF, lexeme: '', line: _line, literal: null));
    return _tokens;
  }

  void _scanToken() {
    String c = _advance();

    switch (c) {
      case '(':
        _addToken(TokenType.LEFT_PAREN);
        break;
      case ')':
        _addToken(TokenType.RIGHT_PAREN);
        break;
      case '{':
        _addToken(TokenType.LEFT_BRACE);
        break;
      case '}':
        _addToken(TokenType.RIGHT_BRACE);
        break;
      case ',':
        _addToken(TokenType.COMMA);
        break;
      case '.':
        _addToken(TokenType.DOT);
        break;
      case '-':
        _addToken(TokenType.MINUS);
        break;
      case '+':
        _addToken(TokenType.PLUS);
        break;
      case ';':
        _addToken(TokenType.SEMICOLON);
        break;
      case '*':
        _addToken(TokenType.STAR);
        break;
      case '!':
        _addToken(_nextMatch('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
        break;
      case '=':
        _addToken(_nextMatch('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
        break;
      case '>':
        _addToken(
            _nextMatch('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
        break;
      case '<':
        _addToken(_nextMatch('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
        break;

      case '/':
        if (_nextMatch('/')) {
          /// 注释的词素一直lookahead
          while (_peek() != '\n' && !_isAtEnd()) {
            _advance();
          }
        } else {
          _addToken(TokenType.SLASH);
        }
        break;

      // 无意义的字符
      case ' ':
      case '\r':
      case '\t':
        break;
      // 换行符
      case '\n':
        _line++;
        break;
      // 字面量
      case '"':
        _string();
        break;
      default:
        if (_isDigit(c)) {
          _number();
        } else if (_isAlpha(c)) {
          _identifier();
        } else {
          Lox.error(_line, 'Unexpected character.');
        }
        break;
    }
  }

  bool _isAtEnd() {
    return _current >= _source.length;
  }

  // 字符串前进一位
  String _advance() {
    _current++;
    return _source[_current - 1];
  }

  void _addToken(TokenType tokenType) {
    _addTokenCurrent(tokenType, null);
  }

  void _addTokenCurrent(TokenType tokenType, dynamic literal) {
    String text = _source.substring(_start, _current);
    _tokens.add(
        Token(type: tokenType, lexeme: text, line: _line, literal: literal));
  }

  bool _nextMatch(String excepted) {
    if (_isAtEnd()) return false;
    if (_source[_current] != excepted) return false;
    _current++;
    return true;
  }

  /// 注释 一直向前
  String _peek() {
    // ignore: unnecessary_string_escapes
    if (_isAtEnd()) return '\0'; // \0 代表空
    return _source[_current];
  }

  /// 处理字符EOF串
  void _string() {
    while (_peek() != '"' && !_isAtEnd()) {
      if (_peek() == '\n') _line++;
      _advance();
    }

    if (_isAtEnd()) {
      Lox.error(_line, 'Unterminated string.');
      return;
    }
    _advance();
    String value = _source.substring(_start + 1, _current - 1);
    _addTokenCurrent(TokenType.STRING, value);
  }

  /// 数字
  bool _isDigit(String c) {
    return c.compareTo('0') >= 0 && c.compareTo('9') <= 0;
  }

  void _number() {
    while (_isDigit(_peek()) && !_isAtEnd()) {
      _advance();
    }
    if (_peek() == '.' && _isDigit(_peekNext()) && !_isAtEnd()) {
      _advance();
      while (_isDigit(_peek())) {
        _advance();
      }
    }
    _addTokenCurrent(
        TokenType.NUMBER, double.parse(_source.substring(_start, _current)));
  }

  String _peekNext() {
    if (_current + 1 >= _source.length) return '\0';
    return _source[_current + 1];
  }

  /// 标识符
  void _identifier() {
    while (_isAlphaNumberic(_peek()) && !_isAtEnd()) {
      _advance();
    }
    String text = _source.substring(_start, _current);
    TokenType? type = _keywords[text];
    type ??= TokenType.IDENTIFIER;

    _addToken(type);
  }

  bool _isAlpha(String c) {
    return (c.compareTo('a') >= 0 && c.compareTo('z') <= 0) ||
        (c.compareTo('A') >= 0 && c.compareTo('Z') <= 0) ||
        c.compareTo('_') == 0;
  }

  bool _isAlphaNumberic(String c) {
    return _isAlpha(c) || _isDigit(c);
  }
}
