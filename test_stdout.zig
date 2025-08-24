const std = @import("std");

pub fn main() !void {
    const stdout_file = std.fs.File.stdout();
    _ = try stdout_file.write("Hello, World!\n");
}