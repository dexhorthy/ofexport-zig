const std = @import("std");
const models = @import("models.zig");

// JXA script to export OmniFocus tasks - complete version (no filtering)
const jxa_script_complete =
    \\(() => {
    \\  const of = Application('OmniFocus');
    \\  const doc = of.defaultDocument;
    \\  const src = doc.flattenedTasks;
    \\  const tasks = typeof src === 'function' ? src() : src;
    \\
    \\  if (!tasks || tasks.length === 0) {
    \\    console.log('[]');
    \\    return;
    \\  }
    \\
    \\  const probe = tasks[0];
    \\  let propNames = [];
    \\
    \\  try {
    \\    for (const k in probe) {
    \\      if (typeof probe[k] === 'function' && probe[k].length === 0 && !k.startsWith('_'))
    \\        propNames.push(k);
    \\    }
    \\  } catch (err) {}
    \\
    \\  if (propNames.length === 0) {
    \\    propNames = [
    \\      'name', 'note', 'creationDate', 'modificationDate', 'completionDate',
    \\      'dueDate', 'deferDate', 'completed', 'flagged', 'estimatedMinutes',
    \\      'effectiveDeferDate', 'effectiveDueDate', 'tags', 'project',
    \\      'parentTask', 'blocked', 'nextTask'
    \\    ];
    \\  }
    \\
    \\  const scrub = (v) => {
    \\    if (v === null || v === undefined) return null;
    \\    if (typeof v === 'boolean' || typeof v === 'number' || typeof v === 'string') return v;
    \\    if (v instanceof Date) return v.toISOString();
    \\    if (Array.isArray(v)) return v.map(scrub);
    \\    if (typeof v.name === 'function') return v.name();
    \\    try { return v.toString(); } catch { return null; }
    \\  };
    \\
    \\  const dump = (t) => {
    \\    const o = {};
    \\    propNames.forEach((p) => {
    \\      try { o[p] = scrub(t[p]()); } catch (_) {}
    \\    });
    \\    try { o.id = t.id.primaryKey; } catch (_) {}
    \\    try { o.url = scrub(t.url()); } catch (_) {}
    \\    try {
    \\      const proj = t.containingProject();
    \\      o.projectName = proj ? scrub(proj.name()) : null;
    \\    } catch (_) {}
    \\    return o;
    \\  };
    \\
    \\  const out = tasks.map(dump);
    \\  console.log(JSON.stringify(out, null, 2));
    \\})();
;

// JXA script to export OmniFocus tasks - filtered version (from script3.js)
const jxa_script_filtered =
    \\(() => {
    \\  const of = Application('OmniFocus');
    \\  const doc = of.defaultDocument;
    \\  const src = doc.flattenedTasks;
    \\  const tasks = typeof src === 'function' ? src() : src;
    \\
    \\  if (!tasks || tasks.length === 0) {
    \\    console.log('[]');
    \\    return;
    \\  }
    \\
    \\  const probe = tasks[0];
    \\  let propNames = [];
    \\
    \\  try {
    \\    for (const k in probe) {
    \\      if (typeof probe[k] === 'function' && probe[k].length === 0 && !k.startsWith('_'))
    \\        propNames.push(k);
    \\    }
    \\  } catch (err) {}
    \\
    \\  if (propNames.length === 0) {
    \\    propNames = [
    \\      'name', 'note', 'creationDate', 'modificationDate', 'completionDate',
    \\      'dueDate', 'deferDate', 'completed', 'flagged', 'estimatedMinutes',
    \\      'effectiveDeferDate', 'effectiveDueDate', 'tags', 'project',
    \\      'parentTask', 'blocked', 'nextTask'
    \\    ];
    \\  }
    \\
    \\  const scrub = (v) => {
    \\    if (v === null || v === undefined) return null;
    \\    if (typeof v === 'boolean' || typeof v === 'number' || typeof v === 'string') return v;
    \\    if (v instanceof Date) return v.toISOString();
    \\    if (Array.isArray(v)) return v.map(scrub);
    \\    if (typeof v.name === 'function') return v.name();
    \\    try { return v.toString(); } catch { return null; }
    \\  };
    \\
    \\  const dump = (t) => {
    \\    const o = {};
    \\    propNames.forEach((p) => {
    \\      try { o[p] = scrub(t[p]()); } catch (_) {}
    \\    });
    \\    try { o.id = t.id.primaryKey; } catch (_) {}
    \\    try { o.url = scrub(t.url()); } catch (_) {}
    \\    try {
    \\      const proj = t.containingProject();
    \\      o.projectName = proj ? scrub(proj.name()) : null;
    \\    } catch (_) {}
    \\    return o;
    \\  };
    \\
    \\  const filtered = tasks.filter((t) => {
    \\    try {
    \\      // Filter out completed tasks
    \\      if (t.completed && t.completed()) return false;
    \\
    \\      // Filter out deferred tasks (effectiveDeferDate is in the future)
    \\      const deferDate = t.effectiveDeferDate ? t.effectiveDeferDate() : null;
    \\      if (deferDate && new Date(deferDate) > new Date()) return false;
    \\
    \\      return true;
    \\    } catch (_) {
    \\      return true; // Include tasks we can't check
    \\    }
    \\  });
    \\
    \\  const out = filtered.map(dump);
    \\  console.log(JSON.stringify(out, null, 2));
    \\})();
;

// JXA script to export inbox tasks only
const jxa_script_inbox =
    \\(() => {
    \\  const of = Application('OmniFocus');
    \\  const doc = of.defaultDocument;
    \\  const inbox = doc.inboxTasks;
    \\  const tasks = typeof inbox === 'function' ? inbox() : inbox;
    \\
    \\  if (!tasks || tasks.length === 0) {
    \\    console.log('[]');
    \\    return;
    \\  }
    \\
    \\  const probe = tasks[0];
    \\  let propNames = [];
    \\
    \\  try {
    \\    for (const k in probe) {
    \\      if (typeof probe[k] === 'function' && probe[k].length === 0 && !k.startsWith('_'))
    \\        propNames.push(k);
    \\    }
    \\  } catch (err) {}
    \\
    \\  if (propNames.length === 0) {
    \\    propNames = [
    \\      'name', 'note', 'creationDate', 'modificationDate', 'completionDate',
    \\      'dueDate', 'deferDate', 'completed', 'flagged', 'estimatedMinutes',
    \\      'effectiveDeferDate', 'effectiveDueDate', 'tags', 'project',
    \\      'parentTask', 'blocked', 'nextTask'
    \\    ];
    \\  }
    \\
    \\  const scrub = (v) => {
    \\    if (v === null || v === undefined) return null;
    \\    if (typeof v === 'boolean' || typeof v === 'number' || typeof v === 'string') return v;
    \\    if (v instanceof Date) return v.toISOString();
    \\    if (Array.isArray(v)) return v.map(scrub);
    \\    if (typeof v.name === 'function') return v.name();
    \\    try { return v.toString(); } catch { return null; }
    \\  };
    \\
    \\  const dump = (t) => {
    \\    const o = {};
    \\    propNames.forEach((p) => {
    \\      try { o[p] = scrub(t[p]()); } catch (_) {}
    \\    });
    \\    try { o.id = t.id.primaryKey; } catch (_) {}
    \\    try { o.url = scrub(t.url()); } catch (_) {}
    \\    try {
    \\      const proj = t.containingProject();
    \\      o.projectName = proj ? scrub(proj.name()) : null;
    \\    } catch (_) {}
    \\    return o;
    \\  };
    \\
    \\  const out = tasks.map(dump);
    \\  console.log(JSON.stringify(out, null, 2));
    \\})();
;

pub const ExportMode = enum {
    complete,
    filtered,
    inbox,
};

pub fn getTasks(allocator: std.mem.Allocator, mode: ExportMode) ![]models.Task {
    // Select the appropriate script based on mode
    const script = switch (mode) {
        .complete => jxa_script_complete,
        .filtered => jxa_script_filtered,
        .inbox => jxa_script_inbox,
    };
    
    // Execute the JXA script using osascript
    const argv = [_][]const u8{ "osascript", "-l", "JavaScript", "-e", script };
    
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    if (result.term != .Exited or result.term.Exited != 0) {
        std.debug.print("Error executing AppleScript: {s}\n", .{result.stderr});
        return error.AppleScriptFailed;
    }

    // Parse JSON output
    const parsed = try std.json.parseFromSlice([]TaskJson, allocator, result.stdout, .{});
    defer parsed.deinit();

    // Convert to our Task model
    var tasks = try std.ArrayList(models.Task).initCapacity(allocator, parsed.value.len);
    defer tasks.deinit(allocator);

    for (parsed.value) |json_task| {
        const task = models.Task{
            .id = if (json_task.id) |id| try allocator.dupe(u8, id) else null,
            .name = if (json_task.name) |name| try allocator.dupe(u8, name) else null,
            .note = if (json_task.note) |note| try allocator.dupe(u8, note) else null,
            .creation_date = if (json_task.creationDate) |date| try allocator.dupe(u8, date) else null,
            .modification_date = if (json_task.modificationDate) |date| try allocator.dupe(u8, date) else null,
            .completion_date = if (json_task.completionDate) |date| try allocator.dupe(u8, date) else null,
            .due_date = if (json_task.dueDate) |date| try allocator.dupe(u8, date) else null,
            .defer_date = if (json_task.deferDate) |date| try allocator.dupe(u8, date) else null,
            .effective_defer_date = if (json_task.effectiveDeferDate) |date| try allocator.dupe(u8, date) else null,
            .effective_due_date = if (json_task.effectiveDueDate) |date| try allocator.dupe(u8, date) else null,
            .completed = json_task.completed orelse false,
            .flagged = json_task.flagged orelse false,
            .blocked = json_task.blocked orelse false,
            .estimated_minutes = json_task.estimatedMinutes,
            .project = if (json_task.project) |proj| try allocator.dupe(u8, proj) else null,
            .project_name = if (json_task.projectName) |name| try allocator.dupe(u8, name) else null,
            .parent_task = if (json_task.parentTask) |task| try allocator.dupe(u8, task) else null,
            .next_task = if (json_task.nextTask) |task| try allocator.dupe(u8, task) else null,
            .url = if (json_task.url) |url| try allocator.dupe(u8, url) else null,
            .tags = &.{}, // TODO: Handle tags array
        };
        try tasks.append(allocator, task);
    }

    return try tasks.toOwnedSlice(allocator);
}

// JSON structure matching the AppleScript output
const TaskJson = struct {
    id: ?[]const u8 = null,
    name: ?[]const u8 = null,
    note: ?[]const u8 = null,
    creationDate: ?[]const u8 = null,
    modificationDate: ?[]const u8 = null,
    completionDate: ?[]const u8 = null,
    dueDate: ?[]const u8 = null,
    deferDate: ?[]const u8 = null,
    effectiveDeferDate: ?[]const u8 = null,
    effectiveDueDate: ?[]const u8 = null,
    completed: ?bool = null,
    flagged: ?bool = null,
    blocked: ?bool = null,
    estimatedMinutes: ?i32 = null,
    tags: ?[][]const u8 = null,
    project: ?[]const u8 = null,
    projectName: ?[]const u8 = null,
    parentTask: ?[]const u8 = null,
    nextTask: ?[]const u8 = null,
    url: ?[]const u8 = null,
};

test "parse empty tasks" {
    const allocator = std.testing.allocator;
    const empty_json = "[]";
    
    const parsed = try std.json.parseFromSlice([]TaskJson, allocator, empty_json, .{});
    defer parsed.deinit();
    
    try std.testing.expectEqual(@as(usize, 0), parsed.value.len);
}

test "parse single task" {
    const allocator = std.testing.allocator;
    const single_task_json =
        \\[{
        \\  "name": "Test Task",
        \\  "completed": false,
        \\  "flagged": true
        \\}]
    ;
    
    const parsed = try std.json.parseFromSlice([]TaskJson, allocator, single_task_json, .{});
    defer parsed.deinit();
    
    try std.testing.expectEqual(@as(usize, 1), parsed.value.len);
    try std.testing.expectEqualStrings("Test Task", parsed.value[0].name.?);
    try std.testing.expect(!parsed.value[0].completed.?);
    try std.testing.expect(parsed.value[0].flagged.?);
}