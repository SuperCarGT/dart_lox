// ignore_for_file: unnecessary_string_interpolations

import 'dart:io';

import 'package:dartlox/src/dart_error.dart';
import 'package:dartlox/src/dart_parser.dart';
import 'package:dartlox/src/dart_token_type.dart';
import 'package:dartlox/visitor/dart_ast_interpreter.dart';
import 'package:dartlox/visitor/dart_ast_printer.dart';

import 'dart_scanner.dart';
import 'dart_smst.dart';
import 'dart_token.dart';

class Lox {
  /// 解释器 访问者模式
  static final Interpreter interpreter = Interpreter();

  static bool hadError = false;
  static bool hadRuntimeError = false;

  static void start(List<String> args) {
    if (args.length > 1) {
      print(args);
    } else if (args.length == 1) {
      runFile(args[0]);
    } else {
      runPrompt();
    }
  }

  static void runFile(String path) async {
    var file = File(path);
    String fileString = await file.readAsString();
    run(fileString);
    if (hadError) exit(65);
    if (hadRuntimeError) exit(70);
  }

  static void runPrompt() {
    for (;;) {
      // print('>');
      stdout.write('> ');
      String? line = stdin.readLineSync();
      if (line == null) break;
      run(line);
      hadError = false;
    }
  }

  static void run(String source) {
    Scanner scanner = Scanner(source);
    List<Token> tokens = scanner.scanTokens();

    stdout.writeln('扫描结果:');
    // For now, just print the tokens.
    for (Token token in tokens) {
      print(token);
    }
    stdout.writeln();
    stdout.writeln('解析表达式:');
    Parser parser = Parser(tokens);
    List<Stmt?> statements = parser.parse();
    // if (statements == null) hadError = true;

    if (hadError) return;

    stdout.writeln(AstPrinter().printer(statements));

    stdout.writeln();

    stdout.writeln('计算表达式:');
    interpreter.interpreter(statements);
  }

  static void error(int line, String message) {
    report(line, 'where', message);
  }

  static void report(int line, String where, String message) {
    print('[line $line] Error $where : $message');
  }

  static errorToken(Token token, String message) {
    if (token.type == TokenType.EOF) {
      report(token.line, 'at end', message);
    } else {
      report(token.line, 'at \'${token.lexeme}\'', message);
    }
  }

  static void runtimeError(RuntimeError error) {
    print('${error.message} \n[line ${error.token.line}]');
    hadRuntimeError = true;
  }
}
