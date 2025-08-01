const Token = @This();

token_type: TokenType,
lexeme: []const u8,

pub const TokenType = union(enum) {
    IDENTIFIER,
    NUMBER: enum { int },
    OPERATOR: enum { equal, plus, minus, times, divideBy },
    PONTUATION: enum { dot, colon, semi_colon, interogation, exclamation, comma },
    SYMBOL: enum { roundBracket, bracket, curlyBracket },
    KEYWORD: enum { function_kw, return_kw, use_kw, as_kw, const_kw, var_kw, class_kw, pub_kw, priv_kw, prot_kw, creator_kw, destroyer_kw, if_kw, else_kw, or_kw, and_kw, for_kw, foreach_kw, while_kw, switch_kw, error_kw, default_kw, try_kw, catch_kw },
    UNKNOWN,
    EOF,
};
