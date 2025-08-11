const Token = @import("token.zig");
const ASTNode = @import("ast.zig");
const std = @import("std");

const Parser = @This();

allocator: std.mem.Allocator,
tokens: []Token,
index: usize = 0,

pub fn init(allocator: std.mem.Allocator, tokens: []Token) Parser {
    return Parser{ .allocator = allocator, .tokens = tokens, .index = 0 };
}

/// Parses the tokens list
/// Returns an array of possibly null ASTNodes
pub fn ParseTokens(self: *Parser) !?[]?*ASTNode {
    var node_list = std.ArrayList(?*ASTNode).init(std.heap.page_allocator);

    while (true) {
        if (self.index >= self.tokens.len) return null;
        const current_token = self.tokens[self.index];

        switch (current_token.token_type) {
            .KEYWORD => |key| {
                switch (key) {
                    .const_kw, .var_kw => {
                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;

                        var tokentype = self.tokens[self.index].token_type;

                        if (tokentype != .IDENTIFIER) return null;

                        const varName = self.tokens[self.index].lexeme;

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;

                        tokentype = self.tokens[self.index].token_type;

                        if (tokentype != .OPERATOR) return null;
                        if (tokentype.OPERATOR != .equal) return null;

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;

                        const value = std.fmt.parseInt(i64, self.tokens[self.index].lexeme, 10) catch return null;

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;

                        tokentype = self.tokens[self.index].token_type;

                        if (tokentype != .PONTUATION) return null;
                        if (tokentype.PONTUATION != .semi_colon) return null;

                        const x_node = self.allocator.create(ASTNode) catch return null;

                        x_node.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value } } };

                        const node = self.allocator.create(ASTNode) catch return null;

                        node.* = .{ .kind = .VariableDeclaration, .data = .{ .VariableDeclaration = .{ .expression = x_node, .name = varName } } };

                        try node_list.append(node);

                        self.index += 1;
                    },
                    else => break,
                }
            },
            .IDENTIFIER => {
                const varName = self.tokens[self.index].lexeme;

                if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                self.index += 1;
                const tokentype = self.tokens[self.index].token_type;

                switch (tokentype) {
                    .OPERATOR => |op| {
                        if (op != .equal) return null;

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;
                        var t2 = self.tokens[self.index].token_type;

                        const value = std.fmt.parseInt(i64, self.tokens[self.index].lexeme, 10) catch return null;

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;
                        t2 = self.tokens[self.index].token_type;

                        if (t2 != .PONTUATION) return null;
                        if (t2.PONTUATION != .semi_colon) return null;

                        const a_node = self.allocator.create(ASTNode) catch return null;

                        a_node.* = .{ .kind = .VariableReference, .data = .{ .VariableReference = .{
                            .name = varName,
                        } } };

                        const v_node = self.allocator.create(ASTNode) catch return null;

                        v_node.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value } } };

                        const node = self.allocator.create(ASTNode) catch return null;

                        node.* = .{ .kind = .Assignment, .data = .{ .Assignment = .{ .variable = a_node, .expression = v_node } } };

                        try node_list.append(node);

                        self.index += 1;
                    },
                    .PONTUATION => {
                        const ref_node = self.allocator.create(ASTNode) catch return null;
                        ref_node.* = .{
                            .kind = .VariableReference,
                            .data = .{ .VariableReference = .{ .name = varName } },
                        };

                        try node_list.append(ref_node);

                        self.index += 1;
                    },
                    else => return null,
                }
            },
            .NUMBER => {
                const v1 = try std.fmt.parseInt(i64, self.tokens[self.index].lexeme, 10);

                const lef_node = self.allocator.create(ASTNode) catch return null;
                lef_node.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = v1 } } };

                if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                self.index += 1;

                var tokentype = self.tokens[self.index].token_type;

                if (tokentype != .OPERATOR) return null;
                if (tokentype.OPERATOR == .equal) return null;

                const op_node: u8 = self.tokens[self.index].lexeme[0];

                if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                self.index += 1;

                tokentype = self.tokens[self.index].token_type;

                const v2 = try std.fmt.parseInt(i64, self.tokens[self.index].lexeme, 10);
                const ri_node = self.allocator.create(ASTNode) catch return null;
                ri_node.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = v2 } } };

                const node = self.allocator.create(ASTNode) catch return null;

                std.debug.print("operation: {} {c} {}\n", .{ v1, op_node, v2 });
                node.* = .{ .kind = .BinaryOperator, .data = .{ .BinaryOperator = .{ .left = lef_node, .operator = op_node, .right = ri_node } } };

                try node_list.append(node);

                self.index += 1;
            },
            .EOF, .UNKNOWN => break,
            else => {},
        }
    }
    return node_list.items;
}
