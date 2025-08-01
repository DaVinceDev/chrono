const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("syntaxv1/basics.chr", .{ .mode = .read_only });

    var contentBuf: [1024]u8 = undefined;
    const contentBytes = try file.readAll(&contentBuf);

    const content = contentBuf[0..contentBytes];

    _ = content;

    //TASKS:
    //  * AMPLIFY THE PARSER
    //  * MAKE A PRETTY PRINTER
}
