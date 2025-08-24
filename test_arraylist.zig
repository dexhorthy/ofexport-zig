const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    var list = std.ArrayList(u32){
        .items = &.{},
        .capacity = 0,
        .allocator = allocator,
    };
    defer list.deinit();
    
    try list.append(42);
    std.debug.print("Item: {}\n", .{list.items[0]});
}
