const std = @import("std");
const applescript = @import("applescript.zig");
const models = @import("models.zig");
const export = @import("export.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Default to filtered export mode
    var export_mode: export.ExportMode = .filtered;
    var output_file: ?[]const u8 = null;

    // Parse command line arguments
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--mode")) {
            if (i + 1 < args.len) {
                i += 1;
                if (std.mem.eql(u8, args[i], "complete")) {
                    export_mode = .complete;
                } else if (std.mem.eql(u8, args[i], "inbox")) {
                    export_mode = .inbox;
                } else if (std.mem.eql(u8, args[i], "filtered")) {
                    export_mode = .filtered;
                } else {
                    std.debug.print("Unknown mode: {s}\n", .{args[i]});
                    std.debug.print("Valid modes: complete, inbox, filtered\n", .{});
                    return;
                }
            }
        } else if (std.mem.eql(u8, args[i], "--output") or std.mem.eql(u8, args[i], "-o")) {
            if (i + 1 < args.len) {
                i += 1;
                output_file = args[i];
            }
        } else if (std.mem.eql(u8, args[i], "--help") or std.mem.eql(u8, args[i], "-h")) {
            printHelp();
            return;
        }
    }

    // Get tasks from OmniFocus
    const tasks = try applescript.getTasks(allocator);
    defer allocator.free(tasks);

    // Apply filtering based on mode
    const filtered_tasks = try export.filterTasks(allocator, tasks, export_mode);
    defer allocator.free(filtered_tasks);

    // Export to JSON
    const json_output = try export.toJson(allocator, filtered_tasks);
    defer allocator.free(json_output);

    // Write output
    if (output_file) |path| {
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();
        try file.writeAll(json_output);
    } else {
        const stdout = std.io.getStdOut().writer();
        try stdout.writeAll(json_output);
    }
}

fn printHelp() void {
    const stdout = std.io.getStdOut().writer();
    stdout.writeAll(
        \\ofexport - Export OmniFocus tasks to JSON
        \\
        \\Usage: ofexport [options]
        \\
        \\Options:
        \\  --mode <mode>     Export mode: complete, inbox, or filtered (default: filtered)
        \\  --output <file>   Output to file instead of stdout
        \\  --help            Show this help message
        \\
        \\Export modes:
        \\  complete  - Export all tasks
        \\  inbox     - Export only inbox tasks
        \\  filtered  - Export active, non-deferred tasks (default)
        \\
    ) catch {};
}

test "main" {
    // Basic test to ensure compilation
    try std.testing.expect(true);
}