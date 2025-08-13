const std = @import("std");
const expect = std.testing.expect;
const Lexer = @import("../src/chrono/lexer.zig");
const Parser = @import("../src/chrono/parser.zig");

test "token list" {
    var file = try std.fs.cwd().openFile("syntaxv1/basics.chro", .{ .mode = .read_only });
    defer file.close();

    var buf: [1024]u8 = undefined;
    const bytes = try file.read(&buf);
    const content = buf[0..bytes];

    var lexer = Lexer.init(content);
    const tokens = try lexer.tokens();

    try expect(tokens.len != 0);
}

test "variable declaration" {
    var file = try std.fs.cwd().openFile("syntaxv1/basics.chro", .{ .mode = .read_only });
    defer file.close();

    var buf: [1024]u8 = undefined;
    const bytes = try file.read(&buf);
    const content = buf[0..bytes];

    var lexer = Lexer.init(content);
    const tokens = try lexer.tokens();

    var parser = Parser.init(std.heap.page_allocator, tokens);
    const tokens_parsed = try parser.ParseTokens();

    try expect(tokens_parsed != null);
    try expect(tokens_parsed.?.len != 0);
}

test "binary operations" {
    var file = try std.fs.cwd().openFile("syntaxv1/operations.chro", .{ .mode = .read_only });
    defer file.close();

    var buf: [1024]u8 = undefined;
    const bytes = try file.read(&buf);
    const content = buf[0..bytes];

    var lexer = Lexer.init(content);
    const tokens = try lexer.tokens();

    var parser = Parser.init(std.heap.page_allocator, tokens);
    const tokens_parsed = try parser.ParseTokens();

    try expect(tokens_parsed != null);
    try expect(tokens_parsed.?.len != 0);
}
