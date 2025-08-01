const Token = @This();

token_type: TokenType,
lexeme: []const u8,

pub const TokenType = enum {
    IDENTIFIER,
    NUMBER,
    OPERATOR,
    PONTUATION,
    SYMBOL,
    KEYWORD,
    UNKNOWN,
    EOF,
    ATTRIBUTE,
};
