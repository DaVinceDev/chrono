const std = @import("std");
const Token = @import("token.zig");
const ASTNode = @import("ast.zig");

const Parser = @This();
pub fn parseVariableDeclaration(allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ?*ASTNode {
    if (index.* >= tokens.len) return null;
    var token_type = tokens[index.*].token_type;

    // Check first token is a KEYWORD (e.g. "const" or "var")
    if (token_type != .KEYWORD) return null;
    // Optionally check if the keyword is the expected one, e.g., "const"
    // if (tokens[index.*].token_keyword != .Const) return null;

    index.* += 1;
    if (index.* >= tokens.len) return null;

    // Now expect an IDENTIFIER token
    token_type = tokens[index.*].token_type;
    if (token_type != .IDENTIFIER) return null;

    const varName = tokens[index.*].lexeme;
    index.* += 1;
    if (index.* >= tokens.len) return null;

    // Expect OPERATOR token with OPERATOR.equal
    token_type = tokens[index.*].token_type;
    if (token_type != .OPERATOR) return null;
    if (token_type.OPERATOR != .equal) return null;

    index.* += 1;
    if (index.* >= tokens.len) return null;

    // Expect NUMBER literal token
    token_type = tokens[index.*].token_type;
    if (token_type != .NUMBER) return null;

    const intVal = parseIntFromLexeme(tokens[index.*].lexeme) orelse return null;
    index.* += 1;
    if (index.* >= tokens.len) return null;

    // Expect PUNCTUATION token with semicolon
    token_type = tokens[index.*].token_type;
    if (token_type != .PONTUATION) return null;

    // Replace ".semi_colon" with your actual enum variant for semicolon
    if (token_type.PONTUATION != .semi_colon) return null;

    index.* += 1;

    // Create number literal AST node
    const expNode = allocator.create(ASTNode) catch return null;
    expNode.* = ASTNode{
        .kind = .NumberLiteral,
        .data = .{ .NumberLiteral = .{ .value = intVal } },
    };

    // Create variable declaration AST node
    const node = allocator.create(ASTNode) catch return null;
    node.* = ASTNode{ .kind = .VariableDeclaration, .data = .{ .VariableDeclaration = .{ .expression = expNode, .name = varName } } };

    return node;
}

// pub fn parseVariableDeclaration(allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ?*ASTNode {
//     if (index.* >= tokens.len) return null;
//
//     const token_type = tokens[index.*].token_type;
//
//     if (token_type != .KEYWORD) return null;
//     index.* += 1;
//
//     if (token_type != .IDENTIFIER) return null;
//     const varName = tokens[index.*].lexeme;
//
//     index.* += 1;
//     if (token_type.OPERATOR != .equal) return null;
//
//     index.* += 1;
//
//     if (token_type != .NUMBER) return null;
//     const intVal = parseIntFromLexeme(tokens[index.*].lexeme) orelse return null;
//
//     index.* += 1;
//
//     if (token_type.PONTUATION != .semi_colon) return null;
//     index.* += 1;
//
//     const expNode = allocator.create(ASTNode) catch return null;
//
//     expNode.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = intVal } } };
//
//     const node = allocator.create(ASTNode) catch return null;
//
//     node.* = .{ .kind = .VariableDeclaration, .data = .{ .VariableDeclaration = .{ .expression = expNode, .name = varName } } };
//
//     return node;
// }

fn parseIntFromLexeme(lexeme: []const u8) ?i64 {
    const num = std.fmt.parseInt(i32, lexeme, 10) catch return null;
    return num;
}
// pub fn parseExpresssion(allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ?*ASTNode {
//     _ = allocator;
//     _ = tokens;
//     _ = index;
// }
