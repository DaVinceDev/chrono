const std = @import("std");
const isAlphanum = std.ascii.isAlphanumeric;
const isAlpha = std.ascii.isAlphabetic;
const isDigit = std.ascii.isDigit;
const isWhitespace = std.ascii.isWhitespace;

pub const Token = struct { token_type: TokenType, lexeme: []const u8 };

pub const TokenType = enum { IDENTIFIER, NUMBER, KEYWORD, OPERATOR, SYMBOL, UNKNOWN, EOF };

pub const Lexer = struct {
    input: []const u8,
    pos: usize,
    line: usize,
    col: usize,

    pub fn init(input: []const u8) Lexer {
        return Lexer{
            .input = input,
            .pos = 0,
            .line = 1,
            .col = 1,
        };
    }
    fn peek(self: *Lexer) ?u8 {
        if (self.pos >= self.input.len) return null;
        return self.input[self.pos];
    }

    fn advance(self: *Lexer) ?u8 {
        const c = self.peek();
        if (c == null) return null;

        self.pos += 1;
        if (c == '\n') {
            self.line += 1;
            self.col = 1;
        } else {
            self.col += 1;
        }
        return c;
    }
    pub fn nextToken(self: *Lexer) Token {
        // Skip whitespace
        while (true) {
            const c = self.peek();
            if (c == null) {
                return Token{ .token_type = .EOF, .lexeme = "" };
            }
            if (c == ' ' or c == '\t' or c == '\n' or c == '\r') {
                _ = self.advance();
                continue;
            }
            break;
        }

        const start_pos = self.pos;
        const c = self.peek() orelse return Token{ .token_type = .EOF, .lexeme = "" };

        // Simple number lexing (integer)
        if (c >= '0' and c <= '9') {
            while (true) {
                const c2 = self.peek();
                if (c2 == null or !(c2.? >= '0' and c2.? <= '9')) break;
                _ = self.advance();
            }
            const lexeme = self.input[start_pos..self.pos];
            return Token{ .token_type = .NUMBER, .lexeme = lexeme };
        }

        // Simple identifier lexing (letters and '_')
        if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c == '_')) {
            while (true) {
                const c2 = self.peek();
                if (c2 == null or
                    !((c2.? >= 'a' and c2.? <= 'z') or (c2.? >= 'A' and c2.? <= 'Z') or (c2.? >= '0' and c2.? <= '9') or (c2.? == '_'))) break;
                _ = self.advance();
            }
            const lexeme = self.input[start_pos..self.pos];

            // For demo, treat "let" as a keyword
            if (std.mem.eql(u8, lexeme, "let")) {
                return Token{ .token_type = .KEYWORD, .lexeme = lexeme };
            }

            return Token{ .token_type = .IDENTIFIER, .lexeme = lexeme };
        }

        // Simple operator lexing (single char operators +-*/)
        const single_char_operators = [_]u8{ '+', '-', '*', '/', '=', ';' };
        for (single_char_operators) |op| {
            if (c == op) {
                _ = self.advance();
                return Token{ .token_type = .OPERATOR, .lexeme = self.input[start_pos..self.pos] };
            }
        }

        // Unknown / unrecognized character
        _ = self.advance();
        return Token{ .token_type = .UNKNOWN, .lexeme = self.input[start_pos..self.pos] };
    }
};
