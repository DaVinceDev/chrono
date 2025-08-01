const std = @import("std");
const Lexer = @import("chrono/lexer.zig");
const Parser = @import("chrono/parser.zig");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("syntaxv1/basics.chr", .{ .mode = .read_only });

    var contentBuf: [1024]u8 = undefined;
    const contentBytes = try file.readAll(&contentBuf);

    const content = contentBuf[0..contentBytes];

    var lexer = Lexer.init(content);

    var allocator = std.heap.page_allocator;

    var index: usize = 0;
    const tokens = try lexer.tokens();
    std.debug.print("Tokens size:{}\n\n", .{tokens.len});
    const nodes = Parser.parseVariableDeclaration(&allocator, tokens, &index);

    if (nodes == null) {
        std.debug.print("Nodes returned null.\n", .{});
    }

    std.debug.print("{}\n\t", .{nodes.?.kind});
    std.debug.print("{}\n", .{nodes.?.data});
}
