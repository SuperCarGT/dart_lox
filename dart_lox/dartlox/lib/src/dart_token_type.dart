// ignore_for_file: constant_identifier_names

enum TokenType{
  // Single-character tokens.
  // 左括号 右括号 
  LEFT_PAREN,
  RIGHT_PAREN, 
  // 左大括号 右大括号
  LEFT_BRACE, 
  RIGHT_BRACE,
  // 逗号
  COMMA, 
  // 小数点
  DOT, 
  // 减号
  MINUS, 
  // 加号
  PLUS, 
  // 分号;
  SEMICOLON, 
  // ÷
  SLASH, 
  // *
  STAR,

  // One or two character tokens.
  // !
  BANG, 
  // !=
  BANG_EQUAL,
  // =
  EQUAL, 
  // ==
  EQUAL_EQUAL,
  // >
  GREATER, 
  // >=
  GREATER_EQUAL,
  // <
  LESS, 
  // <=
  LESS_EQUAL,

  // Literals.
  IDENTIFIER, STRING, NUMBER,

  // Keywords.
  AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR,
  PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE,

  // 结束
  EOF
}