const ASTNode = @This();

kind: NodeKind,
data: union(NodeKind) {
    VariableDeclaration: struct { name: []const u8, expression: ?*ASTNode },

    VariableReference: struct {
        name: []const u8,
    },

    NumberLiteral: struct {
        value: i64,
    },

    BinaryOperator: struct {
        left: *ASTNode,
        operator: u8,
        right: *ASTNode,
    },

    Assignment: struct {
        variable: *ASTNode,
        expression: *ASTNode,
    },
},

pub const NodeKind = enum { VariableDeclaration, VariableReference, NumberLiteral, BinaryOperator, Assignment };
