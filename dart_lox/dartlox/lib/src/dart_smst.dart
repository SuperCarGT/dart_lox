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

import 'dart_expression.dart';

/// 语句访问者
mixin StmtVisitor<R> {
  R visitExpression(Expression expr);
  R visitPrint(Print expr);
  R visitVarStmt(VarStmt expr);
}

abstract class Stmt {
  R accept<R>(StmtVisitor<R> visitor);
}

class Expression extends Stmt {
  final Expr expression;
  Expression(
    this.expression,
  );
  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitExpression(this);
  }
}

class Print extends Stmt {
  final Expr expression;
  Print(
    this.expression,
  );
  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitPrint(this);
  }
}

class VarStmt extends Stmt {
  final Token name;
  final Expr? initializer;

  VarStmt(this.name, this.initializer);

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitVarStmt(this);
  }
}
