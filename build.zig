const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Directory containing each day's solution
    const src_dir = "src";

    // Iterate src/dayXX.zig files
    var dir = try std.fs.cwd().openDir(src_dir, .{ .iterate = true });
    var it = dir.iterate();

    while (try it.next()) |entry| {
        if (entry.kind != .file) continue;

        // Only compile files matching dayXX.zig
        if (!std.mem.startsWith(u8, entry.name, "day")) continue;
        if (!std.mem.endsWith(u8, entry.name, ".zig")) continue;

        const day_name = entry.name[0..5]; // strip .zig → "dayXX"

        // Build target
        const exe = b.addExecutable(.{
            .name = day_name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(src_dir ++ "/" ++ entry.name[0..9]),
                .target = target,
                .optimize = optimize,
            }),
        });

        b.installArtifact(exe);

        // Create `run-dayXX` step
        const run_cmd = b.addRunArtifact(exe);
        const run_step = b.step("run-" ++ day_name, "Run " ++ day_name);
        run_step.dependOn(&run_cmd.step);
    }
}
