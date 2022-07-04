// expression     → equality ;
// equality       → comparison ( ( "!=" | "==" ) comparison )* ;
// comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
// term           → factor ( ( "-" | "+" ) factor )* ;
// factor         → unary ( ( "/" | "*" ) unary )* ;
// unary          → ( "!" | "-" ) unary
//                | primary ;
// primary        → NUMBER | STRING | "true" | "false" | "nil"
//                | "(" expression ")" ;

import 'package:dartlox/src/dart_error.dart';
import 'package:dartlox/src/dart_expression.dart';
import 'package:dartlox/src/dart_smst.dart';
import 'package:dartlox/src/dart_token.dart';
import 'package:dartlox/src/dart_token_type.dart';

import 'dart_lox.dart';

class Parser {
  final List<Token> tokens;
  int current = 0;

  Parser(this.tokens);

  List<Stmt?> parse() {
    List<Stmt?> statements = <Stmt?>[];

    while (!isAtEnd()) {
      statements.add(declaration());
    }

    return statements;
  }

  // declaration    → varDeclaration | statement ;
  Stmt? declaration() {
    try {
      if (match([TokenType.VAR])) return varDeclaration();
      return statement();
    } on ParserError {
      synchronize();
      return null;
    }
  }

  // varDeclaration        → "var" IDENTIFIER ( "=" expression )? ";" ;
  Stmt varDeclaration() {
    Token name = consume(TokenType.IDENTIFIER, 'Expect variable name.');
    Expr? initializer;
    if (match([TokenType.EQUAL])) {
      initializer = expression();
    }
    consume(TokenType.SEMICOLON, 'Expect \';\' after variable declaration.');
    return VarStmt(name, initializer);
  }

  // statement      → exprStmt | printStmt ;
  Stmt statement() {
    if (match([TokenType.PRINT])) return printStatement();
    return expressionStatement();
  }

  Stmt printStatement() {
    Expr expr = expression();
    consume(TokenType.SEMICOLON, 'Expect \';\' after expression.');
    return Print(expr);
  }

  Stmt expressionStatement() {
    Expr expr = expression();
    consume(TokenType.SEMICOLON, 'Expect \';\' after expression.');
    return Expression(expr);
  }

  Expr expression() {
    return comma();
  }

  // 逗号表达式
  // comma  → assignment(','assignment)*
  Expr comma() {
    Expr expr = assignment();
    while (match([TokenType.COMMA])) {
      expr = assignment();
    }
    return expr;
  }

  // assignment     → IDENTIFIER "=" assignment | equality ;
  Expr assignment() {
    Expr expr = equality();
    if (match([TokenType.EQUAL])) {
      Token equals = previous();
      Expr value = assignment();
      if (expr is Variable) {
        Token name = expr.name;
        return Assign(name, value);
      }
      error(equals, "Invalid assignment target.");
    }
    return expr;
  }

  // equality       → comparison ( ( "!=" | "==" ) comparison )* ;
  Expr equality() {
    Expr expr = comparison();

    while (match([TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL])) {
      Token operator = previous();
      Expr right = comparison();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  //comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  Expr comparison() {
    Expr expr = term();
    while (match([
      TokenType.GREATER,
      TokenType.GREATER_EQUAL,
      TokenType.LESS,
      TokenType.LESS_EQUAL,
    ])) {
      Token operator = previous();
      Expr right = term();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }
// term           → factor ( ( "-" | "+" ) factor )* ;

  Expr term() {
    Expr expr = factor();
    while (match([
      TokenType.MINUS,
      TokenType.PLUS,
    ])) {
      Token operator = previous();
      Expr right = factor();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }
// factor         → unary ( ( "/" | "*" ) unary )* ;

  Expr factor() {
    Expr expr = unary();
    while (match([
      TokenType.SLASH,
      TokenType.STAR,
    ])) {
      Token operator = previous();
      Expr right = unary();
      expr = Binary(expr, operator, right);
    }
    return expr;
  }

  // unary          → ( "!" | "-" ) unary
//                | primary ;
  Expr unary() {
    if (match([TokenType.BANG, TokenType.MINUS])) {
      Token operator = previous();
      Expr right = unary();
      return Unary(operator, right);
    }
    return primary();
  }

  // primary        → NUMBER | STRING | "true" | "false" | "nil"
  //                | "(" expression ")" ;
  Expr primary() {
    if (match([TokenType.TRUE])) return Literal(true);
    if (match([TokenType.FALSE])) return Literal(false);
    if (match([TokenType.NIL])) return Literal(null);

    if (match([TokenType.STRING, TokenType.NUMBER])) {
      return Literal(previous().literal);
    }

    if (match([TokenType.IDENTIFIER])) {
      return Variable(previous());
    }

    if (match([TokenType.LEFT_PAREN])) {
      Expr expr = expression();
      consume(TokenType.RIGHT_PAREN, 'Expect \')\' after expression.');
      return Grouping(expr);
    }
    throw error(peek(), 'Expect expression.');
  }

  Token consume(TokenType type, String message) {
    if (check(type)) return advance();
    throw error(peek(), message);
  }

  bool match(List<TokenType> types) {
    for (TokenType type in types) {
      if (check(type)) {
        advance();
        return true;
      }
    }
    return false;
  }

  ParserError error(Token token, String message) {
    Lox.errorToken(token, message);
    return ParserError(message);
  }

  void synchronize() {
    advance();
    while (!isAtEnd()) {
      if (previous().type == TokenType.SEMICOLON) return;
      switch (peek().type) {
        case TokenType.CLASS:
        case TokenType.FUN:
        case TokenType.VAR:
        case TokenType.FOR:
        case TokenType.IF:
        case TokenType.WHILE:
        case TokenType.PRINT:
        case TokenType.RETURN:
          return;
      }
      advance();
    }
  }

  bool check(TokenType type) {
    if (isAtEnd()) return false;
    return peek().type == type;
  }

  Token advance() {
    if (!isAtEnd()) current++;
    return previous();
  }

  bool isAtEnd() {
    return peek().type == TokenType.EOF;
  }

  Token peek() {
    return tokens[current];
  }

  Token previous() {
    return tokens[current - 1];
  }
}
