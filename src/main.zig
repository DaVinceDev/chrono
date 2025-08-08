const std = @import("std");
const Lexer = @import("chrono/lexer.zig");
const Parser = @import("chrono/parser.zig");
const ASTNode = @import("chrono/ast.zig");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("syntaxv1/basics.ksm", .{ .mode = .read_only });

    var contentBuf: [1024]u8 = undefined;
    const contentBytes = try file.readAll(&contentBuf);

    const content = contentBuf[0..contentBytes];

    var lexer = Lexer.init(content);

    var allocator = std.heap.page_allocator;

    var index: usize = 0;
    const tokens = try lexer.tokens();
    std.debug.print("Tokens size:{}\n\n", .{tokens.len});

    const nodes = try Parser.ParseTokens(&allocator, tokens, &index);

    if (nodes != null) {
        for (nodes.?) |node| {
            prettyPrinter(node);
        }
    } else {
        std.debug.print("Nodes returned null.\n", .{});
    }
}

fn prettyPrinter(node: ?*ASTNode) void {
    const nodeKind = node.?.kind;
    const nodeData = node.?.data;

    switch (nodeKind) {
        .Assignment => std.debug.print("Kind: Assignment\n\t", .{}),
        .BinaryOperator => std.debug.print("Kind: BinaryOperator\n\t", .{}),
        .NumberLiteral => std.debug.print("Kind: NumberLiteral\n\t", .{}),
        .VariableDeclaration => std.debug.print("Kind: VariableDeclaration\n\t", .{}),
        .VariableReference => std.debug.print("Kind: VariableReference\n\t", .{}),
    }

    switch (nodeData) {
        .VariableReference => |x| {
            std.debug.print("VariableReference:\n\t", .{});
            std.debug.print("{s}\n", .{x.name});
        },
        .VariableDeclaration => |x| {
            std.debug.print("VariableDeclaration:\n\t", .{});
            std.debug.print("{s}\n", .{x.name});
            std.debug.print("{}\n", .{x.expression.?.*});
        },
        .NumberLiteral => |x| {
            std.debug.print("NumberLiteral:\n\t", .{});
            std.debug.print("{}\n", .{x.value});
        },
        .BinaryOperator => |x| {
            std.debug.print("BinaryOperator:\n\t", .{});
            std.debug.print("Left: {}\n", .{x.left});
            std.debug.print("Operator: {c}\n", .{x.operator});
            std.debug.print("Right: {}\n", .{x.right});
        },
        .Assignment => |x| {
            std.debug.print("Assignment:\n\t", .{});
            std.debug.print("{}\n", .{x.variable.*});
            std.debug.print("{}\n", .{x.expression.*});
        },
    }
}
