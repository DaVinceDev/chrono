const std = @import("std");
const Token = @import("token.zig");
const ASTNode = @import("ast.zig");

const Parser = @This();

pub fn parseVariableDeclaration(allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ?*ASTNode {
    if (tokens[index.*].token_type != .IDENTIFIER) return null;
    const varName = tokens[index.*].lexeme;

    index.* += 1;
    if (tokens[index.*].token_type != .PONTUATION) return null;

    index.* += 1;

    const expression = parseExpresssion(allocator, tokens, index);
    if (expression == null) return null;

    const node = allocator.create(ASTNode) catch return null;

    node.* = .{ .kind = .VariableDeclaration, .data = .{ .VariableDeclaration = .{ .expression = varName, .name = varName } } };

    return node;
}

pub fn parseExpresssion(allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ?*ASTNode {
    _ = allocator;
    _ = tokens;
    _ = index;
}
