const catalog = @import("licenses.zig");
const License = catalog.License;

pub const Status = enum { compatible, conditional, incompatible };

pub const Assessment = struct {
    status: Status,
    reason: []const u8,
};

pub const Candidate = struct {
    license: License,
    status: Status,
};

const compatible = Assessment{ .status = .compatible, .reason = "The source license permits distribution of the combined work under this license, while its notices and source obligations remain in force." };
const incompatible = Assessment{ .status = .incompatible, .reason = "The source license does not permit relicensing its covered work under the target license." };
const retained_notices = Assessment{ .status = .conditional, .reason = "Apply the no-notice license or dedication only to your own contributions. Existing components retain their original licenses, notices, and other conditions; you cannot waive their authors' rights." };
const mpl_files = Assessment{ .status = .conditional, .reason = "Keep MPL-covered source and modifications in separately licensed files under MPL, preserve notices, and provide their source. The target license applies only to other files, not copied MPL source." };
const epl_components = Assessment{ .status = .conditional, .reason = "Keep the EPL program and its covered modifications under EPL, with source, notices, and commercial-distributor obligations. Apply the target license only to separately licensed code outside that covered program; do not copy EPL source into differently licensed files." };
const apache_components = Assessment{ .status = .conditional, .reason = "Retain the Apache component separately under Apache-2.0, including its notices and patent terms. The target applies only to independently licensed surrounding code; it does not replace Apache's terms on copied source." };
const gpl2_conversion = Assessment{ .status = .compatible, .reason = "LGPL-2.1 section 3 permits conveying the covered library under GPL version 2 or any later version; preserve the applicable GPL notices and source obligations." };
const gpl3_conversion = Assessment{ .status = .compatible, .reason = "LGPL-3.0 permits conveying the covered library under GPL-3.0; preserve the applicable GPL notices and source obligations." };
const lgpl_link = Assessment{ .status = .conditional, .reason = "Use the target license only for the surrounding application; keep the library under LGPL, provide its corresponding source, and preserve users' ability to relink a modified library." };
const gpl_agpl_modules = Assessment{ .status = .conditional, .reason = "GPL-3.0 section 13 permits a qualifying separate AGPL module combination; retain each module's license and required notices rather than relicensing either module." };
const mpl_secondary = Assessment{ .status = .conditional, .reason = "MPL-2.0 section 3.3 requires eligible files without the Incompatible With Secondary Licenses restriction and a larger work containing code already under the target GNU license. Additionally offer covered source under MPL and that secondary license, preserving notices and source availability." };
const epl_secondary = Assessment{ .status = .conditional, .reason = "EPL-2.0 section 3.2 requires the initial contributor's explicit Exhibit A notice authorizing this GPL version and combination with separate GPL-licensed files. Include the EPL agreement and preserve notices; the license's template Exhibit A alone is not permission." };
const epl_agpl_modules = Assessment{ .status = .conditional, .reason = "First satisfy EPL-2.0 section 3.2 with an initial-contributor Exhibit A grant authorizing GPL-3.0 and separate GPL-licensed material. Then satisfy GPL/AGPL section 13 for separate modules, retaining their respective licenses; this is not a direct EPL-to-AGPL grant." };
const ofl_bundle = Assessment{ .status = .conditional, .reason = "Keep the font under OFL-1.1, including its Reserved Font Name and redistribution conditions; apply the software license only to software and satisfy OFL font-bundling terms." };

/// Assess whether source-covered work can be included when the combined work
/// is distributed under `target`. This never grants rights over other code.
pub fn assess(existing: License, target: License) Assessment {
    if (existing == target) return compatible;
    if (target == .@"OFL-1.1") return incompatible;
    if (existing == .@"OFL-1.1") return ofl_bundle;

    if ((target == .@"0BSD" or target == .Unlicense) and
        existing.getCategory() == .Permissive and existing != .@"0BSD")
    {
        return retained_notices;
    }

    return switch (existing) {
        .MIT, .@"BSD-2-Clause", .@"BSD-3-Clause", .@"0BSD", .ISC, .@"BSL-1.0", .Zlib, .Unlicense => compatible,
        .@"Apache-2.0" => switch (target) {
            .@"GPL-2.0-only", .@"GPL-2.0-or-later", .@"LGPL-2.1-only", .@"LGPL-2.1-or-later" => incompatible,
            .@"MPL-2.0", .@"EPL-1.0", .@"EPL-2.0" => apache_components,
            else => compatible,
        },
        .@"GPL-2.0-only" => incompatible,
        .@"GPL-2.0-or-later" => switch (target) {
            .@"GPL-2.0-only", .@"GPL-3.0-only", .@"GPL-3.0-or-later" => compatible,
            .@"AGPL-3.0-only", .@"AGPL-3.0-or-later" => gpl_agpl_modules,
            else => incompatible,
        },
        .@"GPL-3.0-only" => switch (target) {
            .@"AGPL-3.0-only", .@"AGPL-3.0-or-later" => gpl_agpl_modules,
            else => incompatible,
        },
        .@"GPL-3.0-or-later" => switch (target) {
            .@"GPL-3.0-only" => compatible,
            .@"AGPL-3.0-only", .@"AGPL-3.0-or-later" => gpl_agpl_modules,
            else => incompatible,
        },
        .@"AGPL-3.0-only" => incompatible,
        .@"AGPL-3.0-or-later" => switch (target) {
            .@"AGPL-3.0-only" => compatible,
            else => incompatible,
        },
        .@"LGPL-2.1-only" => switch (target) {
            .@"GPL-2.0-only", .@"GPL-2.0-or-later", .@"GPL-3.0-only", .@"GPL-3.0-or-later" => gpl2_conversion,
            .MIT,
            .@"BSD-2-Clause",
            .@"BSD-3-Clause",
            .@"Apache-2.0",
            .@"0BSD",
            .ISC,
            .@"BSL-1.0",
            .Zlib,
            .Unlicense,
            .@"MPL-2.0",
            .@"EPL-1.0",
            .@"EPL-2.0",
            .@"AGPL-3.0-only",
            .@"AGPL-3.0-or-later",
            => lgpl_link,
            else => incompatible,
        },
        .@"LGPL-2.1-or-later" => switch (target) {
            .@"GPL-2.0-only", .@"GPL-2.0-or-later", .@"GPL-3.0-only", .@"GPL-3.0-or-later" => gpl2_conversion,
            .@"LGPL-2.1-only", .@"LGPL-3.0-only", .@"LGPL-3.0-or-later" => compatible,
            .MIT,
            .@"BSD-2-Clause",
            .@"BSD-3-Clause",
            .@"Apache-2.0",
            .@"0BSD",
            .ISC,
            .@"BSL-1.0",
            .Zlib,
            .Unlicense,
            .@"MPL-2.0",
            .@"EPL-1.0",
            .@"EPL-2.0",
            .@"AGPL-3.0-only",
            .@"AGPL-3.0-or-later",
            => lgpl_link,
            else => incompatible,
        },
        .@"LGPL-3.0-only" => switch (target) {
            .@"GPL-3.0-only" => gpl3_conversion,
            .MIT,
            .@"BSD-2-Clause",
            .@"BSD-3-Clause",
            .@"Apache-2.0",
            .@"0BSD",
            .ISC,
            .@"BSL-1.0",
            .Zlib,
            .Unlicense,
            .@"MPL-2.0",
            .@"EPL-1.0",
            .@"EPL-2.0",
            .@"AGPL-3.0-only",
            .@"AGPL-3.0-or-later",
            => lgpl_link,
            else => incompatible,
        },
        .@"LGPL-3.0-or-later" => switch (target) {
            .@"GPL-3.0-only", .@"GPL-3.0-or-later" => gpl3_conversion,
            .@"LGPL-3.0-only" => compatible,
            .MIT,
            .@"BSD-2-Clause",
            .@"BSD-3-Clause",
            .@"Apache-2.0",
            .@"0BSD",
            .ISC,
            .@"BSL-1.0",
            .Zlib,
            .Unlicense,
            .@"MPL-2.0",
            .@"EPL-1.0",
            .@"EPL-2.0",
            .@"AGPL-3.0-only",
            .@"AGPL-3.0-or-later",
            => lgpl_link,
            else => incompatible,
        },
        .@"MPL-2.0" => switch (target) {
            .@"GPL-2.0-only",
            .@"GPL-2.0-or-later",
            .@"GPL-3.0-only",
            .@"GPL-3.0-or-later",
            .@"AGPL-3.0-only",
            .@"AGPL-3.0-or-later",
            .@"LGPL-2.1-only",
            .@"LGPL-2.1-or-later",
            .@"LGPL-3.0-only",
            .@"LGPL-3.0-or-later",
            => mpl_secondary,
            else => mpl_files,
        },
        .@"EPL-2.0" => switch (target) {
            .@"GPL-2.0-only", .@"GPL-2.0-or-later", .@"GPL-3.0-only", .@"GPL-3.0-or-later" => epl_secondary,
            .@"AGPL-3.0-only", .@"AGPL-3.0-or-later" => epl_agpl_modules,
            .@"EPL-1.0" => incompatible,
            else => epl_components,
        },
        .@"EPL-1.0" => switch (target) {
            .@"EPL-2.0" => compatible,
            .@"GPL-2.0-only", .@"GPL-2.0-or-later", .@"GPL-3.0-only", .@"GPL-3.0-or-later", .@"AGPL-3.0-only", .@"AGPL-3.0-or-later" => incompatible,
            else => epl_components,
        },
        .@"OFL-1.1" => unreachable,
    };
}

/// All source obligations apply. The strictest individual result controls.
pub fn assessAll(existing: []const License, target: License) Assessment {
    var result = compatible;
    for (existing) |license| {
        const current = assess(license, target);
        if (current.status == .incompatible) return current;
        if (current.status == .conditional) result = current;
    }
    return result;
}

/// Write every candidate accepted for all source licenses into caller storage.
/// An empty source list intentionally produces no candidates.
pub fn findCandidates(existing: []const License, out: *[catalog.all.len]Candidate) []const Candidate {
    if (existing.len == 0) return out[0..0];
    var count: usize = 0;
    for (catalog.all) |license| {
        const assessment = assessAll(existing, license);
        if (assessment.status != .incompatible) {
            out[count] = .{ .license = license, .status = assessment.status };
            count += 1;
        }
    }
    return out[0..count];
}

/// Pair status reports whether a common combined-work license exists, rather
/// than treating directional relicensing in either direction as pair status.
pub fn assessPair(a: License, b: License) Assessment {
    const inputs: [2]License = if (@backingInt(a) <= @backingInt(b)) .{ a, b } else .{ b, a };
    var best: ?Assessment = null;
    for (catalog.all) |target| {
        const combined = assessAll(&inputs, target);
        if (combined.status == .compatible) return combined;
        if (combined.status == .conditional and best == null) best = combined;
    }
    return best orelse Assessment{
        .status = .incompatible,
        .reason = "No supported combined-work license satisfies both source licenses; this does not prevent repository aggregation as separate works under their original terms.",
    };
}
