const std = @import("std");
const eql = std.mem.eql;
const Token = @import("token.zig");

const Lexer = @This();

/// The whole file content in a "string"
input: []const u8,
pos: usize,

pub fn init(input: []const u8) Lexer {
    return Lexer{
        .input = input,
        .pos = 0,
    };
}

/// Checks if the position is greater or equal to the input length
/// Returns null if the condition checks, otherwise returns a character
pub fn peek(self: *Lexer) ?u8 {
    if (self.pos >= self.input.len) return null;
    return self.input[self.pos];
}

/// Returns the next character in the input
/// Returns null if the next character is null
pub fn advance(self: *Lexer) ?u8 {
    const char = self.peek();
    if (char == null) return null;
    self.pos += 1;
    return char;
}

/// Walks the input and returns a Token
/// How it works:
/// First store the current position of the lexer
/// Then checks if the its current character is valid using the `peek` function
/// Then starts doing checks to find the right token for that input
/// At each check uses a suport character to advance in the case the character after the current is valid and advances the position
/// Then with the initial position and the current one, we slice the input and return a token
/// In a loop, the start position is updated at each loop completed so it `walks` the input
pub fn next(self: *Lexer) Token {
    while (true) {
        const current_char = self.peek() orelse return Token{ .lexeme = "", .token_type = .EOF };

        if (self.skipForExtra(current_char)) {
            _ = self.advance();
            continue;
        }
        break;
    }
    const current_char = self.peek() orelse return Token{ .lexeme = "", .token_type = .EOF };

    const start_pos = self.pos;
    if (self.isAlpha(current_char)) {
        while (true) {
            const char2 = self.peek();
            if (char2 == null or !(self.isAlpha(char2.?) or self.isNumber(char2.?))) break;
            _ = self.advance();
        }

        const lexeme = self.input[start_pos..self.pos];
        if (self.isKeyword(lexeme)) {
            return Token{ .lexeme = lexeme, .token_type = .KEYWORD };
        }
        return Token{ .token_type = .IDENTIFIER, .lexeme = lexeme };
    }

    // if (self.isAtrribute(current_char)) {
    //     while (true) {
    //         const char2 = self.peek();
    //         if (char2 == null or !self.isAlpha(char2.?) or self.isSymbol(char2.?)) break;
    //         _ = self.advance();
    //     }
    //     const lexeme = self.input[start_pos..self.pos];
    //     return Token{ .token_type = .ATTRIBUTE, .lexeme = lexeme };
    // }

    if (self.isNumber(current_char)) {
        while (true) {
            const char2 = self.peek();
            if (char2 == null or !(self.isNumber(char2.?))) break;
            _ = self.advance();
        }
        const lexeme = self.input[start_pos..self.pos];
        return Token{ .token_type = .NUMBER, .lexeme = lexeme };
    }

    if (self.isOperator(current_char)) {
        while (true) {
            const char2 = self.peek();
            if (char2 == null or !(self.isOperator(char2.?))) break;
            _ = self.advance();
        }

        const lexeme = self.input[start_pos..self.pos];
        return Token{ .token_type = .OPERATOR, .lexeme = lexeme };
    }
    if (self.isPontuation(current_char)) {
        while (true) {
            const char2 = self.peek();
            if (char2 == null or !(self.isPontuation(char2.?))) break;
            _ = self.advance();
        }

        const lexeme = self.input[start_pos..self.pos];
        return Token{ .token_type = .PONTUATION, .lexeme = lexeme };
    }
    if (self.isSymbol(current_char)) {
        while (true) {
            const char2 = self.peek();
            if (char2 == null or !(self.isSymbol(char2.?))) break;
            _ = self.advance();
        }

        const lexeme = self.input[start_pos..self.pos];
        return Token{ .token_type = .SYMBOL, .lexeme = lexeme };
    }
    _ = self.advance();
    const lexeme = self.input[start_pos..self.pos];
    return Token{ .lexeme = lexeme, .token_type = .UNKNOWN };
}

pub fn skipForExtra(_: *Lexer, char: u8) bool {
    if (char == ' ' or char == '\n' or char == '\r' or char == '\t') {
        return true;
    } else return false;
}

pub fn isAlpha(_: *Lexer, char: u8) bool {
    return (char >= 'a' and char <= 'z') or (char >= 'A' and char <= 'Z');
}

pub fn isNumber(_: *Lexer, char: u8) bool {
    return char >= '0' and char <= '9';
}

pub fn isOperator(_: *Lexer, char: u8) bool {
    if (char == '+' or char == '-' or char == '*' or char == '/' or char == '=') {
        return true;
    } else return false;
}

pub fn isPontuation(_: *Lexer, char: u8) bool {
    if (char == ';' or char == ',' or char == '?' or char == '!' or char == '.' or char == ':') {
        return true;
    } else return false;
}

pub fn isSymbol(_: *Lexer, char: u8) bool {
    if (char == '{' or
        char == '}' or
        char == '[' or
        char == ']' or
        char == '(' or
        char == ')' or
        char == '$' or
        char == '&' or
        char == '\'' or
        char == '"' or
        char == '_')
    {
        return true;
    } else return false;
}

pub fn isKeyword(_: *Lexer, word: []const u8) bool {
    const allocator = std.heap.page_allocator;
    var keyDict = std.StringHashMap([]const u8).init(allocator);
    defer keyDict.deinit();

    _ = keyDict.put("fn", "") catch return false;
    _ = keyDict.put("return", "") catch return false;
    _ = keyDict.put("use", "") catch return false;
    _ = keyDict.put("as", "") catch return false;
    _ = keyDict.put("const", "") catch return false;
    _ = keyDict.put("var", "") catch return false;
    _ = keyDict.put("class", "") catch return false;
    _ = keyDict.put("pub", "") catch return false;
    _ = keyDict.put("priv", "") catch return false;
    _ = keyDict.put("prot", "") catch return false;
    _ = keyDict.put("creator", "") catch return false;
    _ = keyDict.put("destroyer", "") catch return false;
    _ = keyDict.put("if", "") catch return false;
    _ = keyDict.put("else", "") catch return false;
    _ = keyDict.put("or", "") catch return false;
    _ = keyDict.put("and", "") catch return false;
    _ = keyDict.put("for", "") catch return false;
    _ = keyDict.put("foreach", "") catch return false;
    _ = keyDict.put("while", "") catch return false;
    _ = keyDict.put("switch", "") catch return false;
    _ = keyDict.put("error", "") catch return false;
    _ = keyDict.put("default", "") catch return false;
    _ = keyDict.put("try", "") catch return false;
    _ = keyDict.put("catch", "") catch return false;
    return keyDict.contains(word);
}

pub fn tokens(self: *Lexer) ![]Token {
    var map = std.ArrayList(Token).init(std.heap.page_allocator);
    defer map.deinit();

    while (true) {
        const token = self.next();
        if (token.token_type == .EOF) break;
        _ = try map.append(token.lexeme, token.token_type);
    }

    return map.items;
}
