const std = @import("std");

pub const Category = enum {
    Permissive,
    StrongCopyleft,
    WeakCopyleft,
    PublicDomain,
    Font,
};

const only = " This identifier permits only the stated license version, not automatic use of later versions.";
const later = " Recipients may use the stated version or any later version of that GNU license.";
const gpl = "Project-wide copyleft for distributed covered works: provide corresponding source, retain notices, and license the covered combined work under the GPL. Private modifications alone do not require publication.";
const agpl = "Project-wide copyleft with an additional source-offer obligation for users interacting remotely with a modified network version. Retain notices and comply with distribution obligations; this is not a ban on commercial hosting.";
const lgpl = "Library-level copyleft: distributed library modifications remain covered. Separate applications may use different licenses if the LGPL's source, notice, modification, and relinking requirements are met. This does not let you relicense copied library code as proprietary code.";

/// Canonical SPDX identifiers shared by recommendations and compatibility checks.
/// GNU variants are deliberately explicit; ambiguous historical identifiers are rejected.
pub const License = enum {
    MIT,
    @"BSD-2-Clause",
    @"BSD-3-Clause",
    @"Apache-2.0",
    @"0BSD",
    ISC,
    @"BSL-1.0",
    Zlib,
    @"GPL-2.0-only",
    @"GPL-2.0-or-later",
    @"GPL-3.0-only",
    @"GPL-3.0-or-later",
    @"AGPL-3.0-only",
    @"AGPL-3.0-or-later",
    @"LGPL-2.1-only",
    @"LGPL-2.1-or-later",
    @"LGPL-3.0-only",
    @"LGPL-3.0-or-later",
    @"MPL-2.0",
    @"EPL-2.0",
    @"EPL-1.0",
    Unlicense,
    @"OFL-1.1",

    pub fn fromString(text: []const u8) ?License {
        for (all) |license| {
            if (std.ascii.eqlIgnoreCase(text, license.toString())) return license;
        }
        return null;
    }

    pub fn toString(self: License) []const u8 {
        return @tagName(self);
    }

    pub fn getCategory(self: License) Category {
        return switch (self) {
            .MIT, .@"BSD-2-Clause", .@"BSD-3-Clause", .@"Apache-2.0", .@"0BSD", .ISC, .@"BSL-1.0", .Zlib => .Permissive,
            .@"GPL-2.0-only", .@"GPL-2.0-or-later", .@"GPL-3.0-only", .@"GPL-3.0-or-later", .@"AGPL-3.0-only", .@"AGPL-3.0-or-later" => .StrongCopyleft,
            .@"LGPL-2.1-only", .@"LGPL-2.1-or-later", .@"LGPL-3.0-only", .@"LGPL-3.0-or-later", .@"MPL-2.0", .@"EPL-2.0", .@"EPL-1.0" => .WeakCopyleft,
            .Unlicense => .PublicDomain,
            .@"OFL-1.1" => .Font,
        };
    }

    pub fn description(self: License) []const u8 {
        return switch (self) {
            .MIT => "A short permissive license: retain the copyright and license notice in copies or substantial portions. It permits commercial and proprietary derivatives but contains no express contributor patent grant.",
            .@"BSD-2-Clause" => "Permissive licensing with notice requirements for source and binary redistribution. Choose it to match a BSD-2-Clause ecosystem; it is not a less-permissive fallback merely because MIT is shorter.",
            .@"BSD-3-Clause" => "Permissive licensing with source/binary notice requirements and an explicit prohibition on using contributor names to endorse derived products without permission. No express contributor patent grant.",
            .@"Apache-2.0" => "Permissive licensing with an express contributor patent grant and patent-termination terms. Retain required notices, mark changed files, and preserve applicable NOTICE attributions. It is incompatible with GPL-2.0-only for a covered combined program.",
            .@"0BSD" => "A permissive copyright license without a requirement to preserve attribution or license notices. Copyright is retained rather than dedicated to the public domain. No express patent grant or warranty.",
            .ISC => "A short permissive license commonly used in ISC-related ecosystems. Preserve the copyright and permission notice in copies. It is not a no-notice license and contains no express contributor patent grant.",
            .@"BSL-1.0" => "Boost Software License: preserve copyright and license notices in source and covered derivatives; solely machine-executable object-code distributions are exempt from that notice condition. This is not the Business Source License (BUSL-1.1).",
            .Zlib => "Permissive licensing that prohibits misrepresenting origin, requires altered source to be plainly marked, and preserves the notice in source distributions. Product-documentation acknowledgment is appreciated, not required.",
            .@"GPL-2.0-only" => gpl ++ " Use version 2 for a specific existing-project requirement, not simply because it is older." ++ only,
            .@"GPL-2.0-or-later" => gpl ++ " Version 2 is the minimum; selecting version 3 can resolve some compatibility constraints." ++ later,
            .@"GPL-3.0-only" => gpl ++ " Version 3 also includes express contributor patent grants and installation-information rules for covered User Products." ++ only,
            .@"GPL-3.0-or-later" => gpl ++ " Version 3 also includes express contributor patent grants and installation-information rules for covered User Products." ++ later,
            .@"AGPL-3.0-only" => agpl ++ only,
            .@"AGPL-3.0-or-later" => agpl ++ later,
            .@"LGPL-2.1-only" => lgpl ++ " Version 2.1 can be converted to GPL version 2 or a newer published GPL under section 3; that is not automatic permission to upgrade to LGPL version 3." ++ only,
            .@"LGPL-2.1-or-later" => lgpl ++ " Version 2.1 is the minimum; later LGPL versions or the GPL conversion option may be available." ++ later,
            .@"LGPL-3.0-only" => lgpl ++ " Version 3 is a set of additional permissions on top of GPL version 3." ++ only,
            .@"LGPL-3.0-or-later" => lgpl ++ " Version 3 is a set of additional permissions on top of GPL version 3." ++ later,
            .@"MPL-2.0" => "File-level copyleft: distributed covered files and modifications remain under MPL, while separate files may use other licenses. Preserve notices and provide covered source. GNU secondary licensing requires the conditions in section 3.3; it is not unconditional relicensing.",
            .@"EPL-2.0" => "Use for an Eclipse ecosystem requiring EPL. Distributed covered source remains available under EPL; separately linked code may be outside its Modified Works scope. GNU secondary licensing requires the initial contributor's explicit Exhibit A notice. Commercial-distributor obligations also apply.",
            .@"EPL-1.0" => "Use only for a specific existing EPL-1.0 project requirement. Covered contributions retain EPL obligations; it is not a generic alternative to stronger copyleft. The license permits choosing a subsequent EPL version, but does not itself grant GPL secondary licensing.",
            .Unlicense => "A public-domain dedication with a permissive fallback license. It aims to waive copyright restrictions, unlike retaining copyright under 0BSD. Check local enforceability and other rights; it does not grant an express patent license or erase third-party obligations.",
            .@"OFL-1.1" => "Font-specific licensing: fonts may be used, embedded, modified, and bundled, but fonts/derivatives retain OFL and may not be sold by themselves. Preserve notices and respect Reserved Font Names when modifying. Documents created with the fonts do not inherit OFL.",
        };
    }

    pub fn url(self: License) []const u8 {
        inline for (all) |license| {
            if (self == license) return "https://spdx.org/licenses/" ++ @tagName(license) ++ ".html";
        }
        unreachable;
    }
};

pub const all = std.meta.tags(License);
