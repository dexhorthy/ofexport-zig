const std = @import("std");
const models = @import("models.zig");

pub const ExportMode = enum {
    complete,
    inbox,
    filtered,
};

pub fn filterTasks(allocator: std.mem.Allocator, tasks: []const models.Task, mode: ExportMode) ![]models.Task {
    var filtered = std.ArrayList(models.Task).init(allocator);
    defer filtered.deinit();

    for (tasks) |task| {
        const include = switch (mode) {
            .complete => true,
            .inbox => task.isInInbox(),
            .filtered => task.isActive() and !task.completed,
        };

        if (include) {
            try filtered.append(task);
        }
    }

    return try filtered.toOwnedSlice();
}

pub fn toJson(allocator: std.mem.Allocator, tasks: []const models.Task) ![]const u8 {
    var string = std.ArrayList(u8).init(allocator);
    defer string.deinit();

    try std.json.stringify(tasks, .{ .whitespace = .indent_2 }, string.writer());
    try string.append('\n');

    return try string.toOwnedSlice();
}

test "filter complete mode" {
    const allocator = std.testing.allocator;

    const tasks = [_]models.Task{
        .{ .name = "Task 1", .completed = false },
        .{ .name = "Task 2", .completed = true },
        .{ .name = "Task 3", .completed = false },
    };

    const filtered = try filterTasks(allocator, &tasks, .complete);
    defer allocator.free(filtered);

    try std.testing.expectEqual(@as(usize, 3), filtered.len);
}

test "filter inbox mode" {
    const allocator = std.testing.allocator;

    const tasks = [_]models.Task{
        .{ .name = "Inbox Task", .project = null },
        .{ .name = "Project Task", .project = "Some Project" },
    };

    const filtered = try filterTasks(allocator, &tasks, .inbox);
    defer allocator.free(filtered);

    try std.testing.expectEqual(@as(usize, 1), filtered.len);
}

test "filter active mode" {
    const allocator = std.testing.allocator;

    const tasks = [_]models.Task{
        .{ .name = "Active Task", .completed = false },
        .{ .name = "Completed Task", .completed = true },
    };

    const filtered = try filterTasks(allocator, &tasks, .filtered);
    defer allocator.free(filtered);

    try std.testing.expectEqual(@as(usize, 1), filtered.len);
}

test "json export" {
    const allocator = std.testing.allocator;

    const tasks = [_]models.Task{
        .{ .name = "Test Task", .completed = false, .flagged = true },
    };

    const json = try toJson(allocator, &tasks);
    defer allocator.free(json);

    try std.testing.expect(json.len > 0);
    try std.testing.expect(std.mem.indexOf(u8, json, "Test Task") != null);
}