const std = @import("std");
const libflac = @cImport({
    @cInclude("FLAC/metadata.h");
});

pub const TrackMetadata = struct {
    title_length: u32,
    artist_length: u32,
    title: [60]u8,
    artist: [60]u8,
};

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});
    //var metadata_info: libflac.FLAC__StreamMetadata = undefined;
    //_ = libflac.FLAC__metadata_get_streaminfo("test.flac", &metadata_info);
    var vorbis_comment_block_opt: ?*libflac.FLAC__StreamMetadata = null;
    _ = libflac.FLAC__metadata_get_tags("test.flac", &vorbis_comment_block_opt);

    if (vorbis_comment_block_opt) |*vorbis_comment_block| {
        const vorbis_comments = vorbis_comment_block.*.data.vorbis_comment.comments;
        const vorbis_comment_count: u32 = vorbis_comment_block.*.data.vorbis_comment.num_comments;
        var comment_index: u32 = 0;

        const vorbis_artist_tag = "ARTIST";

        while (comment_index < vorbis_comment_count) : (comment_index += 1) {
            const vorbis_comment = vorbis_comments[comment_index];
            if (std.mem.eql(u8, vorbis_artist_tag, vorbis_comment.entry[0..vorbis_artist_tag.len])) {
                std.debug.print("{s}\n", .{vorbis_comment.entry});
                //     std.mem.copyForwards(u8, track_metadata.title[0..], vorbis_comment.entry[0..]);
            }
        }
    }

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
