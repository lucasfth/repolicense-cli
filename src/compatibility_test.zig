const std = @import("std");
const testing = std.testing;
const compatibility = @import("compatibility.zig");
const License = @import("licenses.zig").License;

fn expectStatus(existing: License, target: License, expected: compatibility.Status) !void {
    try testing.expectEqual(expected, compatibility.assess(existing, target).status);
}

test "canonical SPDX names parse and obsolete bare GNU identifiers are rejected" {
    for ([_][]const u8{
        "BSL-1.0",       "Zlib",              "GPL-2.0-only",  "GPL-2.0-or-later",
        "GPL-3.0-only",  "GPL-3.0-or-later",  "AGPL-3.0-only", "AGPL-3.0-or-later",
        "LGPL-2.1-only", "LGPL-2.1-or-later", "LGPL-3.0-only", "LGPL-3.0-or-later",
    }) |id| {
        const parsed = License.fromString(id) orelse return error.ExpectedCanonicalLicense;
        try testing.expectEqualStrings(id, parsed.toString());
    }
    for ([_][]const u8{ "GPL-2.0", "GPL-3.0", "AGPL-3.0", "LGPL-2.1", "LGPL-3.0" }) |id| {
        try testing.expect(License.fromString(id) == null);
    }
}

test "permissive licenses may cover a combined work without erasing source notices" {
    try expectStatus(.MIT, .@"Apache-2.0", .compatible);
    try expectStatus(.@"BSD-3-Clause", .@"GPL-3.0-only", .compatible);
    try expectStatus(.@"Apache-2.0", .@"GPL-3.0-only", .compatible);
    try expectStatus(.Unlicense, .@"GPL-2.0-only", .compatible);
    try expectStatus(.MIT, .@"0BSD", .conditional);
}

test "GPL version and later-version permissions are directional" {
    try expectStatus(.@"GPL-2.0-only", .@"GPL-2.0-only", .compatible);
    try expectStatus(.@"GPL-2.0-only", .@"GPL-2.0-or-later", .incompatible);
    try expectStatus(.@"GPL-2.0-only", .@"GPL-3.0-only", .incompatible);
    try expectStatus(.@"GPL-2.0-or-later", .@"GPL-3.0-only", .compatible);
    try expectStatus(.@"GPL-3.0-only", .@"GPL-3.0-or-later", .incompatible);
    try expectStatus(.@"GPL-3.0-or-later", .@"GPL-3.0-only", .compatible);
    try expectStatus(.@"Apache-2.0", .@"GPL-2.0-only", .incompatible);
    try expectStatus(.@"Apache-2.0", .@"GPL-2.0-or-later", .incompatible);
    try expectStatus(.@"Apache-2.0", .@"GPL-3.0-only", .compatible);
}

test "AGPL section 13 combinations retain each module license" {
    try expectStatus(.@"GPL-3.0-only", .@"AGPL-3.0-only", .conditional);
    try expectStatus(.@"AGPL-3.0-only", .@"GPL-3.0-only", .incompatible);
    try expectStatus(.@"AGPL-3.0-or-later", .@"GPL-3.0-only", .incompatible);
    try expectStatus(.@"AGPL-3.0-only", .@"AGPL-3.0-or-later", .incompatible);
}

test "LGPL conversion and separate-library linking require the correct treatment" {
    try expectStatus(.@"LGPL-2.1-only", .@"GPL-2.0-only", .compatible);
    try expectStatus(.@"LGPL-2.1-only", .@"GPL-3.0-or-later", .compatible);
    try expectStatus(.@"LGPL-2.1-only", .@"GPL-3.0-only", .compatible);
    try expectStatus(.@"LGPL-2.1-only", .@"LGPL-3.0-only", .incompatible);
    try expectStatus(.@"LGPL-3.0-only", .@"GPL-3.0-or-later", .incompatible);
    try expectStatus(.@"LGPL-3.0-or-later", .@"GPL-3.0-only", .compatible);
    try expectStatus(.@"LGPL-3.0-or-later", .@"GPL-3.0-or-later", .compatible);
    try expectStatus(.@"LGPL-2.1-only", .@"Apache-2.0", .conditional);
}

test "MPL and EPL secondary-license requirements are not blanket compatibility" {
    try expectStatus(.@"MPL-2.0", .MIT, .conditional);
    try expectStatus(.@"MPL-2.0", .@"GPL-3.0-only", .conditional);
    try expectStatus(.@"EPL-2.0", .@"GPL-3.0-only", .conditional);
    try expectStatus(.@"EPL-1.0", .@"GPL-3.0-only", .incompatible);
    try expectStatus(.@"EPL-1.0", .MIT, .conditional);
}

test "OFL remains font-scoped and requires separate font terms when bundled" {
    try expectStatus(.@"OFL-1.1", .@"OFL-1.1", .compatible);
    try expectStatus(.@"OFL-1.1", .MIT, .conditional);
    try expectStatus(.MIT, .@"OFL-1.1", .incompatible);
    try expectStatus(.@"OFL-1.1", .@"GPL-3.0-only", .conditional);
}

test "candidate list intersects every source and rejects empty input" {
    var out: [@import("licenses.zig").all.len]compatibility.Candidate = undefined;
    const empty = compatibility.findCandidates(&.{}, &out);
    try testing.expectEqual(@as(usize, 0), empty.len);

    const conflict = [_]License{ .@"GPL-2.0-only", .@"Apache-2.0" };
    const candidates = compatibility.findCandidates(&conflict, &out);
    try testing.expectEqual(@as(usize, 0), candidates.len);

    const allowed = [_]License{ .@"GPL-2.0-or-later", .@"Apache-2.0" };
    const allowed_candidates = compatibility.findCandidates(&allowed, &out);
    var found_gpl3 = false;
    for (allowed_candidates) |candidate| {
        if (candidate.license == .@"GPL-3.0-only") {
            found_gpl3 = true;
            try testing.expectEqual(.compatible, candidate.status);
        }
    }
    try testing.expect(found_gpl3);
    const allowed_reversed = [_]License{ .@"Apache-2.0", .@"GPL-2.0-or-later" };
    var reverse_out: [@import("licenses.zig").all.len]compatibility.Candidate = undefined;
    const reverse_candidates = compatibility.findCandidates(&allowed_reversed, &reverse_out);
    try testing.expectEqual(allowed_candidates.len, reverse_candidates.len);
    for (allowed_candidates, reverse_candidates) |candidate, reversed_candidate| {
        try testing.expectEqual(candidate.license, reversed_candidate.license);
        try testing.expectEqual(candidate.status, reversed_candidate.status);
    }
}

test "assessment of multiple sources is order invariant and honors the strictest status" {
    const inputs = [_]License{ .@"GPL-3.0-only", .@"MPL-2.0" };
    const reversed = [_]License{ .@"MPL-2.0", .@"GPL-3.0-only" };
    const forward = compatibility.assessAll(&inputs, .@"GPL-3.0-only");
    const backward = compatibility.assessAll(&reversed, .@"GPL-3.0-only");
    try testing.expectEqual(forward.status, backward.status);
    try testing.expectEqual(.conditional, forward.status);
}

test "pair assessment is independent of argument order" {
    const forward = compatibility.assessPair(.@"GPL-3.0-only", .@"AGPL-3.0-only");
    const backward = compatibility.assessPair(.@"AGPL-3.0-only", .@"GPL-3.0-only");
    try testing.expectEqual(forward.status, backward.status);
    try testing.expectEqual(.conditional, forward.status);
    try testing.expectEqual(.incompatible, compatibility.assessPair(.@"GPL-2.0-only", .@"Apache-2.0").status);
}

test "LGPL version 3 cannot be combined under GPL version 2 only" {
    try expectStatus(.@"LGPL-3.0-or-later", .@"GPL-2.0-only", .incompatible);
    try testing.expectEqual(.incompatible, compatibility.assessPair(.@"LGPL-3.0-or-later", .@"GPL-2.0-only").status);
}

test "Apache patent terms work with GNU version 3 targets" {
    for ([_]License{ .@"GPL-3.0-only", .@"GPL-3.0-or-later", .@"AGPL-3.0-only", .@"AGPL-3.0-or-later", .@"LGPL-3.0-only", .@"LGPL-3.0-or-later" }) |target| {
        try expectStatus(.@"Apache-2.0", target, .compatible);
    }
}

test "font bundling does not make OFL a software license" {
    try expectStatus(.MIT, .@"OFL-1.1", .incompatible);
}

test "later LGPL version 3 permission permits the corresponding GPL variant" {
    try expectStatus(.@"LGPL-3.0-or-later", .@"GPL-3.0-or-later", .compatible);
}

test "parser accepts case variants but not unknown or compound expressions" {
    try testing.expectEqual(License.MIT, License.fromString("mit").?);
    try testing.expectEqual(License.@"BSL-1.0", License.fromString("bsl-1.0").?);
    try testing.expectEqual(License.@"GPL-3.0-only", License.fromString("gpl-3.0-ONLY").?);
    for ([_][]const u8{ "", "BUSL-1.1", "GPL-4.0-only", "MIT OR Apache-2.0", "MIT AND Zlib" }) |id| {
        try testing.expect(License.fromString(id) == null);
    }
}

test "Boost and Zlib can join GPL work without removing source notices" {
    try expectStatus(.@"BSL-1.0", .@"GPL-2.0-only", .compatible);
    try expectStatus(.Zlib, .@"GPL-3.0-only", .compatible);
    try expectStatus(.@"BSL-1.0", .Unlicense, .conditional);
    try expectStatus(.Zlib, .@"0BSD", .conditional);
}

test "every pair has the same assessment in either order" {
    for (@import("licenses.zig").all) |a| {
        for (@import("licenses.zig").all) |b| {
            const forward = compatibility.assessPair(a, b);
            const reversed = compatibility.assessPair(b, a);
            try testing.expectEqual(forward.status, reversed.status);
            try testing.expectEqualStrings(forward.reason, reversed.reason);
        }
    }
}
