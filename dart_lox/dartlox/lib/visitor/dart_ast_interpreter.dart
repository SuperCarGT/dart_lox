import 'package:dartlox/src/dart_environment.dart';
import 'package:dartlox/src/dart_expression.dart';
import 'package:dartlox/src/dart_smst.dart';
import 'package:dartlox/src/dart_token.dart';
import 'package:dartlox/src/dart_token_type.dart';

import '../src/dart_error.dart';
import '../src/dart_lox.dart';

/// ProjectName: dart_lox
/// Author: gaotong
/// CreateDate: 2022/6/30 2:58 下午
/// Copyright: ©2022 NEW CORE Technology Co. Ltd. All rights reserved.
/// Description:
/// 参数：
/// 返回：
///

class Interpreter implements Visitor<Object?>, StmtVisitor<void> {
  final Environment _environment = Environment();

  void interpreter(List<Stmt?> list) {
    try {
      for (Stmt? element in list) {
        element?.accept(this);
      }
      // Object? object = evaluate(expr);
      // print(stringify(object));
    } on RuntimeError catch (error, _) {
      Lox.runtimeError(error);
    }
  }

  @override
  Object? visitBinary(Binary expr) {
    Object? left = evaluate(expr.left);
    Object? right = evaluate(expr.right);
    switch (expr.operator.type) {
      case TokenType.GREATER:
        checkNumberOperates(expr.operator, left, right);
        return (left as double) > (right as double);
      case TokenType.GREATER_EQUAL:
        checkNumberOperates(expr.operator, left, right);
        return (left as double) >= (right as double);
      case TokenType.LESS:
        checkNumberOperates(expr.operator, left, right);
        return (left as double) < (right as double);
      case TokenType.LESS_EQUAL:
        checkNumberOperates(expr.operator, left, right);
        return (left as double) <= (right as double);
      case TokenType.MINUS:
        checkNumberOperates(expr.operator, left, right);
        return (left as double) - (right as double);
      case TokenType.SLASH:
        checkNumberOperates(expr.operator, left, right);
        if (right is double && right == 0) {
          throw RuntimeError(expr.operator, '/后不能为0');
        }
        return (left as double) / (right as double);
      case TokenType.STAR:
        checkNumberOperates(expr.operator, left, right);
        return (left as double) * (right as double);
      case TokenType.PLUS:
        if (left is double && right is double) {
          return (left) + (right);
        }
        if (left is String || right is String) {
          return stringify(left) + stringify(right);
        }

        throw RuntimeError(
            expr.operator, "Operands must be two numbers or two strings.");
      case TokenType.BANG_EQUAL:
        return !isEqual(left, right);
      case TokenType.EQUAL_EQUAL:
        return isEqual(left, right);
    }
    return null;
  }

  @override
  Object? visitGrouping(Grouping expr) {
    return evaluate(expr.expression);
  }

  @override
  Object? visitLiteral(Literal expr) {
    return expr.value;
  }

  @override
  Object? visitUnary(Unary expr) {
    Object? right = evaluate(expr);
    switch (expr.operator.type) {
      case TokenType.MINUS:
        checkNumberOperate(expr.operator, right);
        return -(double.parse(right.toString()));
      case TokenType.BANG:
        return !(isTruthy(right));
    }
    return null;
  }

  @override
  void visitExpression(Expression expr) {
    evaluate(expr.expression);
  }

  @override
  void visitPrint(Print expr) {
    Object? value = evaluate(expr.expression);
    print(stringify(value));
  }

  void checkNumberOperate(Token operate, Object? number) {
    if (number.runtimeType == double) return;
    throw RuntimeError(operate, 'Operand must be a number.');
  }

  void checkNumberOperates(Token operate, Object? left, Object? right) {
    if (left.runtimeType == double && right.runtimeType == double) return;
    throw RuntimeError(operate, 'Operand must be a number.');
  }

  Object? evaluate(Expr expr) {
    return expr.accept(this);
  }

  bool isTruthy(Object? object) {
    if (object == null) return false;
    if (object.runtimeType == bool) return (object as bool);
    return true;
  }

  bool isEqual(Object? a, Object? b) {
    if (a == null && b == null) return true;
    if (a == null) return false;

    return a == b;
  }

  String stringify(Object? object) {
    if (object == null) return 'null';
    if (object is double) {
      String text = object.toString();
      if (text.endsWith('.0')) {
        text = text.substring(0, text.length - 2);
      }
      return text;
    }
    return object.toString();
  }

  @override
  Object? visitVariable(Variable expr) {
    return _environment.get(expr.name);
  }

  @override
  void visitVarStmt(VarStmt stmt) {
    dynamic value;
    if (stmt.initializer != null) {
      value = evaluate(stmt.initializer!);
    }
    _environment.define(stmt.name.lexeme, value);
  }

  @override
  Object? visitAssign(Assign expr) {
    Object? value = evaluate(expr.value);
    _environment.assign(expr.name, value);
    return value;
  }
}
