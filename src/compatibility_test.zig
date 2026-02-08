const std = @import("std");
const testing = std.testing;
const compatibility = @import("compatibility.zig");

test "License fromString and toString roundtrip" {
    const licenses = [_][]const u8{
        "MIT",
        "BSD-2-Clause",
        "Apache-2.0",
        "GPL-3.0",
        "LGPL-3.0",
    };

    for (licenses) |license_str| {
        const lic = compatibility.License.fromString(license_str);
        try testing.expect(lic != null);
        try testing.expectEqualStrings(license_str, lic.?.toString());
    }
}

test "License fromString returns null for invalid input" {
    try testing.expect(compatibility.License.fromString("Invalid") == null);
    try testing.expect(compatibility.License.fromString("") == null);
    try testing.expect(compatibility.License.fromString("mit") == null); // Case sensitive
}

test "getCategory returns correct categories" {
    try testing.expect(compatibility.License.MIT.getCategory() == .Permissive);
    try testing.expect(compatibility.License.Apache_2_0.getCategory() == .Permissive);
    try testing.expect(compatibility.License.GPL_3_0.getCategory() == .StrongCopyleft);
    try testing.expect(compatibility.License.AGPL_3_0.getCategory() == .StrongCopyleft);
    try testing.expect(compatibility.License.LGPL_3_0.getCategory() == .WeakCopyleft);
    try testing.expect(compatibility.License.MPL_2_0.getCategory() == .WeakCopyleft);
    try testing.expect(compatibility.License.Unlicense.getCategory() == .PublicDomain);
    try testing.expect(compatibility.License.OFL_1_1.getCategory() == .Specialized);
}

test "same license is always compatible" {
    try testing.expect(compatibility.isCompatible(.MIT, .MIT));
    try testing.expect(compatibility.isCompatible(.GPL_3_0, .GPL_3_0));
    try testing.expect(compatibility.isCompatible(.Apache_2_0, .Apache_2_0));
}

test "Unlicense is compatible with everything" {
    try testing.expect(compatibility.isCompatible(.Unlicense, .MIT));
    try testing.expect(compatibility.isCompatible(.Unlicense, .GPL_3_0));
    try testing.expect(compatibility.isCompatible(.Unlicense, .Apache_2_0));
    try testing.expect(compatibility.isCompatible(.Unlicense, .LGPL_3_0));
}

test "MIT is broadly compatible" {
    try testing.expect(compatibility.isCompatible(.MIT, .MIT));
    try testing.expect(compatibility.isCompatible(.MIT, .Apache_2_0));
    try testing.expect(compatibility.isCompatible(.MIT, .GPL_3_0));
    try testing.expect(compatibility.isCompatible(.MIT, .BSD_3_Clause));
    try testing.expect(!compatibility.isCompatible(.MIT, .OFL_1_1)); // Font license is specialized
}

test "Apache-2.0 and GPL-2.0 are incompatible" {
    try testing.expect(!compatibility.isCompatible(.Apache_2_0, .GPL_2_0));
}

test "Apache-2.0 is compatible with GPL-3.0" {
    try testing.expect(compatibility.isCompatible(.Apache_2_0, .GPL_3_0));
}

test "GPL-3.0 is restrictive in compatibility" {
    try testing.expect(compatibility.isCompatible(.GPL_3_0, .GPL_3_0));
    try testing.expect(compatibility.isCompatible(.GPL_3_0, .AGPL_3_0));
    try testing.expect(!compatibility.isCompatible(.GPL_3_0, .MIT));
    try testing.expect(!compatibility.isCompatible(.GPL_3_0, .Apache_2_0));
    try testing.expect(!compatibility.isCompatible(.GPL_3_0, .LGPL_3_0));
}

test "AGPL-3.0 is most restrictive" {
    try testing.expect(compatibility.isCompatible(.AGPL_3_0, .AGPL_3_0));
    try testing.expect(!compatibility.isCompatible(.AGPL_3_0, .GPL_3_0));
    try testing.expect(!compatibility.isCompatible(.AGPL_3_0, .MIT));
}

test "LGPL-3.0 allows more combinations" {
    try testing.expect(compatibility.isCompatible(.LGPL_3_0, .MIT));
    try testing.expect(compatibility.isCompatible(.LGPL_3_0, .Apache_2_0));
    try testing.expect(compatibility.isCompatible(.LGPL_3_0, .GPL_3_0));
    try testing.expect(compatibility.isCompatible(.LGPL_3_0, .MPL_2_0));
}

test "MPL-2.0 weak copyleft compatibility" {
    try testing.expect(compatibility.isCompatible(.MPL_2_0, .MIT));
    try testing.expect(compatibility.isCompatible(.MPL_2_0, .Apache_2_0));
    try testing.expect(compatibility.isCompatible(.MPL_2_0, .GPL_3_0));
    try testing.expect(!compatibility.isCompatible(.MPL_2_0, .OFL_1_1));
}

test "OFL-1.1 is specialized and restrictive" {
    try testing.expect(compatibility.isCompatible(.OFL_1_1, .OFL_1_1));
    try testing.expect(!compatibility.isCompatible(.OFL_1_1, .MIT));
    try testing.expect(!compatibility.isCompatible(.OFL_1_1, .GPL_3_0));
}

test "findCompatibleLicenses with single MIT license" {
    const allocator = testing.allocator;
    const existing = [_]compatibility.License{.MIT};
    
    const compatible = try compatibility.findCompatibleLicenses(allocator, &existing);
    defer allocator.free(compatible);
    
    // MIT should allow many licenses
    try testing.expect(compatible.len > 0);
    
    // Should include common permissive licenses
    var found_mit = false;
    var found_apache = false;
    var found_gpl3 = false;
    
    for (compatible) |lic| {
        if (lic == .MIT) found_mit = true;
        if (lic == .Apache_2_0) found_apache = true;
        if (lic == .GPL_3_0) found_gpl3 = true;
    }
    
    try testing.expect(found_mit);
    try testing.expect(found_apache);
    try testing.expect(found_gpl3);
}

test "findCompatibleLicenses with GPL-3.0" {
    const allocator = testing.allocator;
    const existing = [_]compatibility.License{.GPL_3_0};
    
    const compatible = try compatibility.findCompatibleLicenses(allocator, &existing);
    defer allocator.free(compatible);
    
    // GPL-3.0 is restrictive, should only allow GPL-3.0 and AGPL-3.0
    try testing.expect(compatible.len == 2);
    
    var found_gpl3 = false;
    var found_agpl3 = false;
    
    for (compatible) |lic| {
        if (lic == .GPL_3_0) found_gpl3 = true;
        if (lic == .AGPL_3_0) found_agpl3 = true;
    }
    
    try testing.expect(found_gpl3);
    try testing.expect(found_agpl3);
}

test "findCompatibleLicenses with MIT and Apache-2.0" {
    const allocator = testing.allocator;
    const existing = [_]compatibility.License{ .MIT, .Apache_2_0 };
    
    const compatible = try compatibility.findCompatibleLicenses(allocator, &existing);
    defer allocator.free(compatible);
    
    // Both are permissive, should allow many licenses
    try testing.expect(compatible.len > 0);
}

test "findCompatibleLicenses with conflicting licenses" {
    const allocator = testing.allocator;
    const existing = [_]compatibility.License{ .GPL_3_0, .OFL_1_1 };
    
    const compatible = try compatibility.findCompatibleLicenses(allocator, &existing);
    defer allocator.free(compatible);
    
    // These are incompatible, should find no compatible licenses
    try testing.expect(compatible.len == 0);
}

test "getCompatibilityReason returns non-empty string" {
    const reason1 = compatibility.getCompatibilityReason(.MIT, .MIT);
    try testing.expect(reason1.len > 0);
    
    const reason2 = compatibility.getCompatibilityReason(.MIT, .GPL_3_0);
    try testing.expect(reason2.len > 0);
    
    const reason3 = compatibility.getCompatibilityReason(.Apache_2_0, .GPL_2_0);
    try testing.expect(reason3.len > 0);
}
