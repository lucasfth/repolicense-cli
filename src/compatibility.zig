const std = @import("std");

/// License compatibility checker for determining which licenses can be used
/// when forking/combining projects with existing licenses.
///
/// Compatibility rules are based on common open-source license compatibility:
/// - Permissive licenses (MIT, BSD, Apache) are generally compatible with everything
/// - Copyleft licenses (GPL, AGPL) require derivatives to use the same or compatible license
/// - Some licenses (Apache-2.0 + GPL-2.0) have known incompatibilities

pub const License = enum {
    MIT,
    BSD_2_Clause,
    BSD_3_Clause,
    Apache_2_0,
    @"0BSD",
    ISC,
    AGPL_3_0,
    GPL_3_0,
    GPL_2_0,
    LGPL_3_0,
    MPL_2_0,
    EPL_2_0,
    EPL_1_0,
    Unlicense,
    OFL_1_1,

    pub fn fromString(s: []const u8) ?License {
        const map = std.ComptimeStringMap(License, .{
            .{ "MIT", .MIT },
            .{ "BSD-2-Clause", .BSD_2_Clause },
            .{ "BSD-3-Clause", .BSD_3_Clause },
            .{ "Apache-2.0", .Apache_2_0 },
            .{ "0BSD", .@"0BSD" },
            .{ "ISC", .ISC },
            .{ "AGPL-3.0", .AGPL_3_0 },
            .{ "GPL-3.0", .GPL_3_0 },
            .{ "GPL-2.0", .GPL_2_0 },
            .{ "LGPL-3.0", .LGPL_3_0 },
            .{ "MPL-2.0", .MPL_2_0 },
            .{ "EPL-2.0", .EPL_2_0 },
            .{ "EPL-1.0", .EPL_1_0 },
            .{ "Unlicense", .Unlicense },
            .{ "OFL-1.1", .OFL_1_1 },
        });
        return map.get(s);
    }

    pub fn toString(self: License) []const u8 {
        return switch (self) {
            .MIT => "MIT",
            .BSD_2_Clause => "BSD-2-Clause",
            .BSD_3_Clause => "BSD-3-Clause",
            .Apache_2_0 => "Apache-2.0",
            .@"0BSD" => "0BSD",
            .ISC => "ISC",
            .AGPL_3_0 => "AGPL-3.0",
            .GPL_3_0 => "GPL-3.0",
            .GPL_2_0 => "GPL-2.0",
            .LGPL_3_0 => "LGPL-3.0",
            .MPL_2_0 => "MPL-2.0",
            .EPL_2_0 => "EPL-2.0",
            .EPL_1_0 => "EPL-1.0",
            .Unlicense => "Unlicense",
            .OFL_1_1 => "OFL-1.1",
        };
    }

    pub fn getCategory(self: License) LicenseCategory {
        return switch (self) {
            .MIT, .BSD_2_Clause, .BSD_3_Clause, .Apache_2_0, .@"0BSD", .ISC => .Permissive,
            .AGPL_3_0, .GPL_3_0, .GPL_2_0 => .StrongCopyleft,
            .LGPL_3_0, .MPL_2_0, .EPL_2_0, .EPL_1_0 => .WeakCopyleft,
            .Unlicense => .PublicDomain,
            .OFL_1_1 => .Specialized,
        };
    }
};

pub const LicenseCategory = enum {
    Permissive,
    StrongCopyleft,
    WeakCopyleft,
    PublicDomain,
    Specialized,
};

/// Checks if a new license can be used when combining with existing licenses
/// Returns true if the combination is compatible
pub fn isCompatible(existing: License, new_license: License) bool {
    // Public domain and permissive licenses can be combined with anything
    if (existing.getCategory() == .PublicDomain or existing == .Unlicense) {
        return true;
    }

    // Same license is always compatible
    if (existing == new_license) {
        return true;
    }

    // Check compatibility based on existing license
    return switch (existing) {
        // Permissive licenses accept most things, but derivatives must respect their terms
        .MIT, .BSD_2_Clause, .BSD_3_Clause, .ISC, .@"0BSD" => switch (new_license.getCategory()) {
            .Permissive, .PublicDomain, .WeakCopyleft, .StrongCopyleft => true,
            .Specialized => false, // Font licenses are specialized
        },

        // Apache-2.0 has patent grant issues with GPL-2.0
        .Apache_2_0 => switch (new_license) {
            .GPL_2_0 => false, // Known incompatibility
            else => switch (new_license.getCategory()) {
                .Permissive, .PublicDomain => true,
                .WeakCopyleft => true,
                .StrongCopyleft => new_license == .GPL_3_0 or new_license == .AGPL_3_0,
                .Specialized => false,
            },
        },

        // Strong copyleft licenses require derivative works to be under compatible copyleft
        .GPL_3_0 => switch (new_license) {
            .GPL_3_0, .AGPL_3_0 => true,
            else => false,
        },

        .GPL_2_0 => switch (new_license) {
            .GPL_2_0, .GPL_3_0 => true,
            else => false,
        },

        .AGPL_3_0 => switch (new_license) {
            .AGPL_3_0 => true,
            else => false,
        },

        // LGPL allows linking with other software
        .LGPL_3_0 => switch (new_license.getCategory()) {
            .Permissive, .PublicDomain, .WeakCopyleft => true,
            .StrongCopyleft => new_license == .GPL_3_0 or new_license == .AGPL_3_0,
            .Specialized => false,
        },

        // Weak copyleft licenses are file-level copyleft
        .MPL_2_0 => switch (new_license.getCategory()) {
            .Permissive, .PublicDomain, .WeakCopyleft => true,
            .StrongCopyleft => new_license == .GPL_3_0 or new_license == .AGPL_3_0,
            .Specialized => false,
        },

        .EPL_2_0, .EPL_1_0 => switch (new_license.getCategory()) {
            .Permissive, .PublicDomain, .WeakCopyleft => true,
            .StrongCopyleft => false,
            .Specialized => false,
        },

        .Unlicense => true, // Public domain

        .OFL_1_1 => switch (new_license) {
            .OFL_1_1 => true,
            else => false,
        },
    };
}

/// Find all compatible licenses given a list of existing licenses
/// Allocates and returns a list of compatible licenses
pub fn findCompatibleLicenses(allocator: std.mem.Allocator, existing_licenses: []const License) ![]const License {
    var compatible = std.ArrayList(License).init(allocator);
    defer compatible.deinit();

    // All possible licenses to check
    const all_licenses = [_]License{
        .MIT,
        .BSD_2_Clause,
        .BSD_3_Clause,
        .Apache_2_0,
        .@"0BSD",
        .ISC,
        .AGPL_3_0,
        .GPL_3_0,
        .GPL_2_0,
        .LGPL_3_0,
        .MPL_2_0,
        .EPL_2_0,
        .EPL_1_0,
        .Unlicense,
        .OFL_1_1,
    };

    // Check each possible license against all existing licenses
    for (all_licenses) |candidate| {
        var is_compatible_with_all = true;
        for (existing_licenses) |existing| {
            if (!isCompatible(existing, candidate)) {
                is_compatible_with_all = false;
                break;
            }
        }

        if (is_compatible_with_all) {
            try compatible.append(candidate);
        }
    }

    return compatible.toOwnedSlice();
}

/// Get a brief explanation of why licenses are compatible or not
pub fn getCompatibilityReason(existing: License, new_license: License) []const u8 {
    if (existing == new_license) {
        return "Same license - fully compatible";
    }

    const compatible = isCompatible(existing, new_license);

    if (compatible) {
        return switch (existing.getCategory()) {
            .PublicDomain => "Public domain allows any license",
            .Permissive => "Permissive licenses are broadly compatible",
            .WeakCopyleft => "Weak copyleft allows compatible combinations",
            .StrongCopyleft => "Strong copyleft requires compatible copyleft license",
            .Specialized => "Specialized licenses have specific rules",
        };
    } else {
        if (existing == .Apache_2_0 and new_license == .GPL_2_0) {
            return "Apache-2.0 and GPL-2.0 have patent grant incompatibility";
        }
        return switch (existing.getCategory()) {
            .StrongCopyleft => "Strong copyleft requires derivative under same/compatible license",
            .Specialized => "Specialized licenses restrict combination with other types",
            else => "License terms are incompatible",
        };
    }
}
