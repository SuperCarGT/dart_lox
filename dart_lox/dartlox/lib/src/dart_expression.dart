// expression     → literal
//                | unary
//                | binary
//                | grouping ;
// literal        → NUMBER | STRING | "true" | "false" | "nil" ;
// grouping       → "(" expression ")" ;
// unary          → ( "-" | "!" ) expression ;
// binary         → expression operator expression ;
// operator       → "==" | "!=" | "<" | "<=" | ">" | ">="
//                | "+"  | "-"  | "*" | "/" ;

import 'package:dartlox/src/dart_token.dart';

mixin Visitor<R> {
  R visitBinary(Binary expr);
  R visitGrouping(Grouping expr);
  R visitLiteral(Literal expr);
  R visitUnary(Unary expr);
  R visitVariable(Variable expr);
  R visitAssign(Assign expr);
}

abstract class Expr {
  R accept<R>(Visitor<R> visitor);
}

class Binary extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;
  Binary(
    this.left,
    this.operator,
    this.right,
  );
  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitBinary(this);
  }
}

class Grouping extends Expr {
  final Expr expression;
  Grouping(
    this.expression,
  );
  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitGrouping(this);
  }
}

class Literal extends Expr {
  final dynamic value;
  Literal(
    this.value,
  );
  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitLiteral(this);
  }
}

class Unary extends Expr {
  final Token operator;
  final Expr right;
  Unary(
    this.operator,
    this.right,
  );
  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitUnary(this);
  }
}

class Variable extends Expr {
  final Token name;
  Variable(this.name);
  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitVariable(this);
  }
}

class Assign extends Expr {
  final Token name;
  final Expr value;

  Assign(this.name, this.value);
  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitAssign(this);
  }
}
