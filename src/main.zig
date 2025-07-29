const std = @import("std");
const ChronoLexer = @import("lexer.zig");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("syntaxv1/network.chr", .{ .mode = .read_only });

    var contentBuf: [1024]u8 = undefined;
    const contentBytes = try file.readAll(&contentBuf);

    const content = contentBuf[0..contentBytes];

    var lexer = ChronoLexer.Lexer.init(content);

    while (true) {
        const token = lexer.next();
        std.debug.print("[TOKEN]:{s}\t[TYPE]:{}\n", .{ token.lexeme, token.token_type });
        std.time.sleep(100000000);
        if (token.token_type == .EOF) break;
    }
}
