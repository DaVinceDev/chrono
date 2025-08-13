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

                        if (tokentype != .IDENTIFIER) return error.ExpectedIdentifier;

                        const varName = self.tokens[self.index].lexeme;

                        //
                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;

                        tokentype = self.tokens[self.index].token_type;

                        if (tokentype != .PUNCTUATION) return error.ExpectedPuntuaction;
                        if (tokentype.PUNCTUATION != .colon) return error.ExpectedPuntuactionColon;

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;

                        tokentype = self.tokens[self.index].token_type;

                        if (tokentype != .IDENTIFIER) return error.ExpectedIdentifier;

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;

                        tokentype = self.tokens[self.index].token_type;

                        if (tokentype != .OPERATOR) return error.ExpectedOperator;
                        if (tokentype.OPERATOR != .equal) return error.ExpectedOperatorEqual;

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;

                        const value = try std.fmt.parseInt(i64, self.tokens[self.index].lexeme, 10);

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;

                        tokentype = self.tokens[self.index].token_type;

                        if (tokentype == .OPERATOR) {
                            if (tokentype.OPERATOR == .equal) return error.UnexpectedOperatorEqual;

                            const oper: u8 = self.tokens[self.index].lexeme[0];

                            if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                            self.index += 1;

                            const value2 = try std.fmt.parseInt(i64, self.tokens[self.index].lexeme, 10);

                            if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                            self.index += 1;
                            tokentype = self.tokens[self.index].token_type;

                            if (tokentype != .PUNCTUATION) {
                                std.debug.print("Error: Expected puntuaction type got: {s} with type: {}\n", .{ self.tokens[self.index].lexeme, self.tokens[self.index].token_type });
                                return error.ExpectedPuntuaction;
                            }
                            if (tokentype.PUNCTUATION != .semi_colon) return error.ExpectedPuntuactionSemiColon;

                            const l_node = try self.allocator.create(ASTNode);

                            l_node.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value } } };
                            const r_node = try self.allocator.create(ASTNode);

                            r_node.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value2 } } };

                            const bin_node = try self.allocator.create(ASTNode);

                            bin_node.* = .{ .kind = .BinaryOperation, .data = .{ .BinaryOperation = .{ .left = l_node, .right = r_node, .operator = oper } } };

                            const varRef = try self.allocator.create(ASTNode);

                            varRef.* = .{ .kind = .VariableReference, .data = .{ .VariableReference = .{ .name = varName } } };

                            const node = try self.allocator.create(ASTNode);

                            node.* = .{ .kind = .VariableDeclaration, .data = .{ .Assignment = .{ .expression = bin_node, .variable = varRef } } };

                            try node_list.append(node);

                            self.index += 1;
                        } else if (tokentype == .PUNCTUATION) {
                            if (tokentype.PUNCTUATION != .semi_colon) return error.ExpectedPuntuactionSemiColon;

                            const x_node = try self.allocator.create(ASTNode);

                            x_node.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value } } };

                            const node = try self.allocator.create(ASTNode);

                            node.* = .{ .kind = .VariableDeclaration, .data = .{ .VariableDeclaration = .{ .expression = x_node, .name = varName } } };

                            try node_list.append(node);

                            self.index += 1;
                        }
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
                    // ASSIGNMENT
                    // Procedure:
                    // IDENTIFIER
                    // operator
                    // binary expression
                    // semi_colon
                    .OPERATOR => |op| {
                        if (op != .equal) return error.ExpectedOperatorEqual;

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;
                        var t2 = self.tokens[self.index].token_type;

                        const value = try std.fmt.parseInt(i64, self.tokens[self.index].lexeme, 10);

                        if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                        self.index += 1;
                        t2 = self.tokens[self.index].token_type;

                        if (t2 == .PUNCTUATION) {
                            if (t2.PUNCTUATION != .semi_colon) return error.ExpectedPuntuactionSemiColon;

                            const a_node = try self.allocator.create(ASTNode);

                            a_node.* = .{ .kind = .VariableReference, .data = .{ .VariableReference = .{
                                .name = varName,
                            } } };

                            const v_node = try self.allocator.create(ASTNode);

                            v_node.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value } } };

                            const node = try self.allocator.create(ASTNode);

                            node.* = .{ .kind = .Assignment, .data = .{ .Assignment = .{ .variable = a_node, .expression = v_node } } };

                            try node_list.append(node);

                            self.index += 1;
                        } else if (t2 == .OPERATOR) {
                            if (t2.OPERATOR == .equal) return null;

                            const oper: u8 = self.tokens[self.index].lexeme[0];

                            if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                            self.index += 1;

                            const value2 = try std.fmt.parseInt(i64, self.tokens[self.index].lexeme, 10);

                            if (self.index + 1 >= self.tokens.len or self.tokens[self.index + 1].token_type == .EOF) return null;
                            self.index += 1;
                            t2 = self.tokens[self.index].token_type;

                            if (t2 != .PUNCTUATION) {
                                std.debug.print("Error: Expected puntuaction type got: {s} with type: {}\n", .{ self.tokens[self.index].lexeme, self.tokens[self.index].token_type });
                                return error.ExpectedPuntuaction;
                            }
                            if (t2.PUNCTUATION != .semi_colon) return error.ExpectedPuntuactionSemiColon;

                            const l_node = try self.allocator.create(ASTNode);

                            l_node.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value } } };
                            const r_node = try self.allocator.create(ASTNode);

                            r_node.* = .{ .kind = .NumberLiteral, .data = .{ .NumberLiteral = .{ .value = value2 } } };

                            const bin_node = try self.allocator.create(ASTNode);

                            bin_node.* = .{ .kind = .BinaryOperation, .data = .{ .BinaryOperation = .{ .left = l_node, .right = r_node, .operator = oper } } };

                            const varRef = try self.allocator.create(ASTNode);

                            varRef.* = .{ .kind = .VariableReference, .data = .{ .VariableReference = .{ .name = varName } } };

                            const node = try self.allocator.create(ASTNode);

                            node.* = .{ .kind = .Assignment, .data = .{ .Assignment = .{ .expression = bin_node, .variable = varRef } } };

                            try node_list.append(node);

                            self.index += 1;
                        }
                    },
                    // VARIABLE REFERENCE
                    .PUNCTUATION => |p| {
                        if (p == .colon) return error.UnexpectedOperatorColon;
                        const ref_node = try self.allocator.create(ASTNode);
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
                node.* = .{ .kind = .BinaryOperation, .data = .{ .BinaryOperation = .{ .left = lef_node, .operator = op_node, .right = ri_node } } };

                try node_list.append(node);

                self.index += 1;
            },
            .EOF, .UNKNOWN => break,
            else => {},
        }
    }
    return node_list.items;
}
