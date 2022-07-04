import 'package:dartlox/src/dart_expression.dart';

import '../src/dart_error.dart';
import '../src/dart_lox.dart';
import '../src/dart_smst.dart';

/// 访问者模式

class AstPrinter implements Visitor<String>, StmtVisitor<String> {
  String? printer(List<Stmt?> list) {
    try {
      String output = '';
      for (Stmt? element in list) {
        output += '${element?.accept(this)}\n';
      }
      return output;
      // Object? object = evaluate(expr);
      // print(stringify(object));
    } on RuntimeError catch (error, _) {
      Lox.runtimeError(error);
      return null;
    }
  }

  @override
  String visitBinary(Binary expr) {
    return parentheSize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGrouping(Grouping expr) {
    return parentheSize('group', [expr.expression]);
  }

  @override
  String visitLiteral(Literal expr) {
    if (expr.value == null) return 'null';
    return expr.value.toString();
  }

  @override
  String visitUnary(Unary expr) {
    return parentheSize(expr.operator.lexeme, [expr.right]);
  }

  String parentheSize(String name, List<Expr>? exprs) {
    StringBuffer builder = StringBuffer('(');
    builder.write(name);
    exprs?.forEach((element) {
      builder.write(' ');
      builder.write(element.accept(this));
    });
    builder.write(')');
    return builder.toString();
  }

  @override
  String visitExpression(Expression expr) {
    return parentheSize('statement', [expr.expression]);
  }

  @override
  String visitPrint(Print expr) {
    return parentheSize('print statement', [expr.expression]);
  }

  @override
  String visitVarStmt(VarStmt stmt) {
    return parentheSize('var statement ${stmt.name.lexeme}',
        stmt.initializer != null ? [stmt.initializer!] : null);
  }

  @override
  String visitVariable(Variable expr) {
    return parentheSize(expr.name.lexeme, null);
  }

  @override
  String visitAssign(Assign expr) {
    return parentheSize(expr.name.lexeme, [expr.value]);
  }
}
