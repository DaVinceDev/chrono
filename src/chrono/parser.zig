const Token = @import("token.zig");
const ASTNode = @import("ast.zig");
const std = @import("std");

const Parser = @This();

pub fn advance(tokens: []Token, index: *usize, token_type: *Token.TokenType) void {
    if (index.* + 1 >= tokens.len) {
        index.* = tokens.len;
        token_type.* = .EOF;
    } else {
        index.* += 1;
        token_type.* = tokens[index.*].token_type;
    }
}

pub fn ParseTokens(allocator: *std.mem.Allocator, tokens: []Token, index: *usize) !?[]?*ASTNode {
    var node_list = std.ArrayList(?*ASTNode).init(std.heap.page_allocator);

    while (true) {
        if (index.* >= tokens.len) {
            std.debug.print("Index reached or surpassed tokens length!\n", .{});
            return null;
        }
        const token_type = tokens[index.*].token_type;
        switch (token_type) {
            .KEYWORD => |key| {
                switch (key) {
                    .const_kw, .var_kw => {
                        const node = parseVariableDeclaration(allocator, tokens, index);
                        if (index.* >= tokens.len or tokens[index.* + 1].token_type == .EOF) break;
                        if (node != null)
                            try node_list.append(node);
                    },
                    else => {},
                }
            },
            .IDENTIFIER => {
                const node = parseAssignment(allocator, tokens, index);
                if (index.* >= tokens.len or tokens[index.* + 1].token_type == .EOF) break;
                if (node != null) {
                    try node_list.append(node);
                } else {
                    const fallback_node = parseVariableReference(allocator, tokens, index);
                    if (index.* >= tokens.len or tokens[index.* + 1].token_type == .EOF) break;
                    if (fallback_node != null) {
                        try node_list.append(fallback_node);
                    } else {}
                }
                // const node = parseVariableReference(allocator, tokens, index);
                // if (index.* >= tokens.len or tokens[index.* + 1].token_type == .EOF) break;
                // if (node != null) {
                //     try node_list.append(node);
                // } else {
                //     const fallback_node = parseAssignment(allocator, tokens, index);
                //     if (index.* >= tokens.len or tokens[index.* + 1].token_type == .EOF) break;
                //     if (fallback_node != null) {
                //         try node_list.append(fallback_node);
                //     } else {}
                // }
            },
            .EOF, .UNKNOWN => break,
            else => {},
        }
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

    const xprsNode = allocator.create(ASTNode) catch return null;

    xprsNode.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value } } };

    const node = allocator.create(ASTNode) catch return null;

    node.* = .{ .kind = .VariableDeclaration, .data = .{ .VariableDeclaration = .{ .name = varName, .expression = xprsNode } } };

    advance(tokens, index, &token_type);
    return node;
}

pub fn parseVariableReference(allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ?*ASTNode {
    if (index.* >= tokens.len) return null;

    var token_type = tokens[index.*].token_type;

    if (token_type != .IDENTIFIER) return null;

    const varName = tokens[index.*].lexeme;

    advance(tokens, index, &token_type);

    if (token_type != .PONTUATION) return null;
    if (token_type.PONTUATION != .semi_colon) return null;

    const node = allocator.create(ASTNode) catch return null;

    node.* = .{ .kind = .VariableReference, .data = .{ .VariableReference = .{ .name = varName } } };

    advance(tokens, index, &token_type);

    return node;
}

pub fn parseAssignment(allocator: *std.mem.Allocator, tokens: []Token, index: *usize) ?*ASTNode {
    if (index.* >= tokens.len) return null;

    var token_type = tokens[index.*].token_type;

    if (token_type != .IDENTIFIER) return null;

    const varName = tokens[index.*].lexeme;

    advance(tokens, index, &token_type);

    if (token_type != .OPERATOR) return null;
    if (token_type.OPERATOR != .equal) return null;

    advance(tokens, index, &token_type);

    const value = parseIntFromLexeme(tokens[index.*].lexeme) orelse return null;

    const varRef = allocator.create(ASTNode) catch return null;

    varRef.* = .{ .kind = .VariableReference, .data = .{ .VariableReference = .{ .name = varName } } };

    advance(tokens, index, &token_type);

    const xprsNode = allocator.create(ASTNode) catch return null;

    xprsNode.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value } } };

    const node = allocator.create(ASTNode) catch return null;

    node.* = .{ .kind = .Assignment, .data = .{ .Assignment = .{ .variable = varRef, .expression = xprsNode } } };

    advance(tokens, index, &token_type);

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
//
fn parseIntFromLexeme(lexeme: []const u8) ?i64 {
    const num = std.fmt.parseInt(i32, lexeme, 10) catch return null;
    return num;
}
