import 'dart:io';

void main(List<String> args) {
  String outputDir = args[0];
  // GenerateAst().defineAst(outputDir, 'Expr', [
  //   'Binary   : Expr left, Token operator, Expr right',
  //   'Grouping : Expr expression',
  //   'Literal  : dynamic value',
  //   'Unary    : Token operator, Expr right'
  // ]);
  GenerateAst().defineAst(outputDir, 'Stmt', [
    "Expression : Expr expression",
    "Print      : Expr expression",
  ]);
}

class GenerateAst {
  void defineAst(String outputDir, String baseName, List<String> types) {
    // String path = '$outputDir/$baseName.dart';
    var file = File(outputDir);
    var link = file.openWrite();
    link.writeln(
        '// expression     → literal\n//                | unary\n//                | binary\n//                | grouping ;\n// literal        → NUMBER | STRING | "true" | "false" | "nil" ;\n// grouping       → "(" expression ")" ;\n// unary          → ( "-" | "!" ) expression ;\n// binary         → expression operator expression ;\n// operator       → "==" | "!=" | "<" | "<=" | ">" | ">="\n//                | "+"  | "-"  | "*" | "/" ;');
    link.writeln();
    link.writeln('import \'package:dartlox/src/dart_token.dart\';');
    link.writeln();

    /// 接口
    defineVisitor(link, types);

    defineAbstract(link, baseName);
    for (String type in types) {
      String className = type.split(':')[0].trim();
      String fields = type.split(':')[1].trim();
      link.writeln('class $className extends $baseName {');
      defineFields(link, fields, className);
      link.writeln('}');
    }
    link.flush().then((value) {
      link.close();
    });
  }

  void defineAbstract(IOSink link, String baseName) {
    /// 基类
    link.writeln('abstract class $baseName {');
    link.writeln('  R accept<R>(Visitor<R> visitor);');
    link.writeln('}');
  }

  void defineFields(IOSink link, String fieldList, String className) {
    List<String> fields = fieldList.split(', ');
    String constructor = '';
    for (String field in fields) {
      String name = field.split(' ')[1];
      link.writeln('  final $field;');
      constructor += 'this.$name,';
    }
    link.writeln('  $className($constructor);');
    link.writeln('  @override');
    link.writeln('  R accept<R>(Visitor<R> visitor) {');
    link.writeln('    return visitor.visit$className(this);');
    link.writeln('  }');
  }

  void defineVisitor(IOSink link, List<String> types) {
    link.writeln('mixin Visitor<R> {');
    for (String type in types) {
      String className = type.split(':')[0].trim();
      link.writeln('  R visit$className($className expr);');
    }

    link.writeln('}');
  }
}
