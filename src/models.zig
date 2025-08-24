const std = @import("std");

pub const Task = struct {
    id: ?[]const u8 = null,
    name: ?[]const u8 = null,
    note: ?[]const u8 = null,
    creation_date: ?[]const u8 = null,
    modification_date: ?[]const u8 = null,
    completion_date: ?[]const u8 = null,
    due_date: ?[]const u8 = null,
    defer_date: ?[]const u8 = null,
    effective_defer_date: ?[]const u8 = null,
    effective_due_date: ?[]const u8 = null,
    completed: bool = false,
    flagged: bool = false,
    blocked: bool = false,
    estimated_minutes: ?i32 = null,
    tags: []const []const u8 = &.{},
    project: ?[]const u8 = null,
    project_name: ?[]const u8 = null,
    parent_task: ?[]const u8 = null,
    next_task: ?[]const u8 = null,
    url: ?[]const u8 = null,

    pub fn isActive(self: Task) bool {
        // Task is active if not completed and not deferred to the future
        if (self.completed) return false;
        
        if (self.effective_defer_date) |defer_date| {
            // Parse ISO date and check if it's in the future
            // For now, simplified check - would need proper date parsing
            // This is a placeholder that should be replaced with actual date comparison
            _ = defer_date;
            // TODO: Implement proper date comparison
        }
        
        return true;
    }

    pub fn isInInbox(self: Task) bool {
        // Task is in inbox if it has no project
        return self.project == null or self.project_name == null;
    }

    pub fn toJson(self: Task, allocator: std.mem.Allocator) ![]const u8 {
        var string = try std.ArrayList(u8).initCapacity(allocator, 512);
        defer string.deinit(allocator);
        
        // Manual JSON generation for now
        try string.appendSlice(allocator, "{\n");
        
        if (self.id) |id| {
            try string.appendSlice(allocator, "  \"id\": \"");
            try string.appendSlice(allocator, id);
            try string.appendSlice(allocator, "\",\n");
        }
        
        if (self.name) |name| {
            try string.appendSlice(allocator, "  \"name\": \"");
            try string.appendSlice(allocator, name);
            try string.appendSlice(allocator, "\",\n");
        }
        
        try string.appendSlice(allocator, "  \"completed\": ");
        try string.appendSlice(allocator, if (self.completed) "true" else "false");
        try string.appendSlice(allocator, ",\n");
        
        try string.appendSlice(allocator, "  \"flagged\": ");
        try string.appendSlice(allocator, if (self.flagged) "true" else "false");
        try string.appendSlice(allocator, "\n}");
        
        return try string.toOwnedSlice(allocator);
    }
};

pub const Project = struct {
    id: []const u8,
    name: []const u8,
    status: []const u8,
};

pub const Tag = struct {
    id: []const u8,
    name: []const u8,
};

test "Task creation" {
    const task = Task{
        .name = "Test Task",
        .completed = false,
        .flagged = true,
    };
    
    try std.testing.expect(task.isActive());
    try std.testing.expect(!task.isInInbox());
}

test "Task in inbox" {
    const task = Task{
        .name = "Inbox Task",
        .completed = false,
        .project = null,
    };
    
    try std.testing.expect(task.isInInbox());
}