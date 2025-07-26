const std = @import("std");
const ChronoLexer = @import("lexer.zig");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("test1.chr", .{ .mode = .read_only });

    var contentBuf: [1024]u8 = undefined;
    const contentBytes = try file.readAll(&contentBuf);

    const content = contentBuf[0..contentBytes];

    // const source = "const x = 10;";
    var lexer = ChronoLexer.Lexer.init(content);
    while (true) {
        const token = lexer.nextToken();
        std.debug.print("Token: {}, Lexeme: {s}\n", .{ token.token_type, token.lexeme });
        if (token.token_type == ChronoLexer.TokenType.EOF) break;
    }
}
