const Token = @import("token.zig");
const ASTNode = @import("ast.zig");
const std = @import("std");

const Parser = @This();

pub fn advance(tokens: []Token, index: *usize, token_type: *Token.TokenType) void {
    index.* += 1;
    if (index.* >= tokens.len) return;
    token_type.* = tokens[index.*].token_type;
}

pub fn ParseTokens(allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ![]?*ASTNode {
    var node_list = std.ArrayList(?*ASTNode).init(std.heap.page_allocator);

    while (true) {
        const node = parseVariableDeclaration(allocator, tokens, index);
        if (node == null) break;
        try node_list.append(node);
    }

    return node_list.items;
}

pub fn parseVariableDeclaration(allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ?*ASTNode {
    // Procedure:
    // 1. keyword
    // 2. identifier
    // 3. symbol \ null
    // 4. type | null
    // 5. assign operator
    // 6. Value

    if (index.* >= tokens.len) return null;
    var token_type = tokens[index.*].token_type;

    if (token_type != .KEYWORD) return null;

    advance(tokens, index, &token_type);

    if (token_type != .IDENTIFIER) return null;

    const varName = tokens[index.*].lexeme;

    advance(tokens, index, &token_type);

    if (token_type != .OPERATOR) return null;

    if (token_type.OPERATOR != .equal) return null;

    advance(tokens, index, &token_type);

    const value = parseIntFromLexeme(tokens[index.*].lexeme) orelse return null;

    advance(tokens, index, &token_type);

    if (token_type != .PONTUATION) return null;
    if (token_type.PONTUATION != .semi_colon) return null;

    index.* += 1;

    const xprsNode = allocator.create(ASTNode) catch return null;

    xprsNode.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value } } };

    const node = allocator.create(ASTNode) catch return null;

    node.* = .{ .kind = .VariableDeclaration, .data = .{ .VariableDeclaration = .{ .name = varName, .expression = xprsNode } } };

    return node;
}

// pub fn parseFunctionDeclaration(_: *Parser, allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ?*ASTNode {
//     // Procedure:
//     // 1. keyword
//     // 2. identifier
//     // 3. parameters
//     // 4. pontuation | null
//     // 5. type
//     // 6. blocks
//     //
//     _ = allocator
// }
//
// pub fn parseVariableReference(_: *Parser, allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ?*ASTNode {}
//
fn parseIntFromLexeme(lexeme: []const u8) ?i64 {
    const num = std.fmt.parseInt(i32, lexeme, 10) catch return null;
    return num;
}
