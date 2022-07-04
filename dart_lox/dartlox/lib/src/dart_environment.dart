import 'package:dartlox/src/dart_error.dart';
import 'package:dartlox/src/dart_token.dart';

/// ProjectName: dart_lox
/// Author: gaotong
/// CreateDate: 2022/7/1 6:10 下午
/// Copyright: ©2022 NEW CORE Technology Co. Ltd. All rights reserved.
/// Description:
/// 参数：
/// 返回：
///
class Environment {
  final Map<String, dynamic> values = {};
  define(String name, dynamic value) {
    values[name] = value;
  }

  dynamic get(Token name) {
    if (values.containsKey(name.lexeme)) {
      return values[name.lexeme];
    }
    throw RuntimeError(name, 'Undefined variable "${name.lexeme}".');
  }

  void assign(Token name, dynamic value) {
    if (values.containsKey(name.lexeme)) {
      values[name.lexeme] = value;
      return;
    }
    throw RuntimeError(name, 'Undefined variable "${name.lexeme}".');
  }
}
