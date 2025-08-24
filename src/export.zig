const std = @import("std");
const models = @import("models.zig");
const applescript = @import("applescript.zig");

// Re-export the ExportMode from applescript module
pub const ExportMode = applescript.ExportMode;

pub fn toJson(allocator: std.mem.Allocator, tasks: []const models.Task) ![]const u8 {
    // For now, use manual JSON generation until we figure out the API
    var string = try std.ArrayList(u8).initCapacity(allocator, 1024);
    defer string.deinit(allocator);

    try string.appendSlice(allocator, "[\n");
    
    for (tasks, 0..) |task, i| {
        if (i > 0) {
            try string.appendSlice(allocator, ",\n");
        }
        try string.appendSlice(allocator, "  {\n");
        
        if (task.id) |id| {
            try string.appendSlice(allocator, "    \"id\": \"");
            try string.appendSlice(allocator, id);
            try string.appendSlice(allocator, "\",\n");
        }
        
        if (task.name) |name| {
            try string.appendSlice(allocator, "    \"name\": \"");
            try string.appendSlice(allocator, name);
            try string.appendSlice(allocator, "\",\n");
        }
        
        if (task.note) |note| {
            try string.appendSlice(allocator, "    \"note\": \"");
            try string.appendSlice(allocator, note);
            try string.appendSlice(allocator, "\",\n");
        }
        
        if (task.project_name) |project| {
            try string.appendSlice(allocator, "    \"project\": \"");
            try string.appendSlice(allocator, project);
            try string.appendSlice(allocator, "\",\n");
        }
        
        if (task.due_date) |due| {
            try string.appendSlice(allocator, "    \"dueDate\": \"");
            try string.appendSlice(allocator, due);
            try string.appendSlice(allocator, "\",\n");
        }
        
        if (task.creation_date) |created| {
            try string.appendSlice(allocator, "    \"creationDate\": \"");
            try string.appendSlice(allocator, created);
            try string.appendSlice(allocator, "\",\n");
        }
        
        try string.appendSlice(allocator, "    \"completed\": ");
        try string.appendSlice(allocator, if (task.completed) "true" else "false");
        try string.appendSlice(allocator, ",\n");
        
        try string.appendSlice(allocator, "    \"flagged\": ");
        try string.appendSlice(allocator, if (task.flagged) "true" else "false");
        
        if (task.estimated_minutes) |minutes| {
            try string.appendSlice(allocator, ",\n    \"estimatedMinutes\": ");
            const minutes_str = try std.fmt.allocPrint(allocator, "{d}", .{minutes});
            defer allocator.free(minutes_str);
            try string.appendSlice(allocator, minutes_str);
        }
        
        try string.appendSlice(allocator, "\n");
        
        try string.appendSlice(allocator, "  }");
    }
    
    try string.appendSlice(allocator, "\n]\n");

    return try string.toOwnedSlice(allocator);
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