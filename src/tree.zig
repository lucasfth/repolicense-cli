const catalog = @import("licenses.zig");

pub const NodeType = enum {
    Question,
    Answer,
};

pub const Node = struct {
    node_type: NodeType,
    content: []const u8,
    elaboration: []const u8,
    yes: ?*const Node,
    no: ?*const Node,
    license: ?catalog.License = null,
};

pub const decision_tree = buildDecisionTree();

fn question(content: []const u8, elaboration: []const u8, yes: *const Node, no: *const Node) Node {
    return .{
        .node_type = .Question,
        .content = content,
        .elaboration = elaboration,
        .yes = yes,
        .no = no,
    };
}

fn recommendation(comptime license: catalog.License) Node {
    return .{
        .node_type = .Answer,
        .content = license.toString(),
        .elaboration = license.description(),
        .yes = null,
        .no = null,
        .license = license,
    };
}

fn advice(content: []const u8, elaboration: []const u8) Node {
    return .{
        .node_type = .Answer,
        .content = content,
        .elaboration = elaboration,
        .yes = null,
        .no = null,
    };
}

fn buildDecisionTree() Node {
    const font_advice = advice(
        "No font license recommendation matches these preferences.",
        "Review the font's existing terms and permissions; font licensing and software licensing differ, and this tool only recommends the SIL Open Font License when its stated goals fit.",
    );
    const ownership_advice = advice(
        "Verify that you have the right to license this software.",
        "Identify authors, employers, contributors, and third-party components, then resolve ownership and existing obligations before selecting a license.",
    );
    const reserved_rights_advice = advice(
        "An open-source license does not match these reserved-rights preferences.",
        "Open-source licenses grant broad rights to use, modify, and redistribute. Review proprietary or other specialized terms with qualified counsel; this tool does not draft or recommend a proprietary license.",
    );
    const unmatched_copyleft_advice = advice(
        "No copyleft recommendation matches these preferences.",
        "The selected scope does not match the copyleft options represented here. Compare the obligations of project-wide, library-boundary, and file-level copyleft before choosing a license.",
    );

    const mit = recommendation(.MIT);
    const bsd2 = recommendation(.@"BSD-2-Clause");
    const bsd3 = recommendation(.@"BSD-3-Clause");
    const apache = recommendation(.@"Apache-2.0");
    const zero_bsd = recommendation(.@"0BSD");
    const isc = recommendation(.ISC);
    const boost = recommendation(.@"BSL-1.0");
    const zlib = recommendation(.Zlib);
    const unlicense = recommendation(.Unlicense);
    const ofl = recommendation(.@"OFL-1.1");

    const isc_preference = question(
        "Do you prefer the ISC ecosystem and wording?",
        "ISC is a short permissive license requiring its copyright and permission notice to be retained in copies. It does not waive notices or include an express contributor patent grant.",
        &isc,
        &mit,
    );
    const bsd_preference = question(
        "Do you prefer the BSD-2-Clause ecosystem and wording?",
        "BSD-2-Clause preserves notices in source and requires their reproduction in documentation or other materials with binary distributions, without BSD-3-Clause's endorsement clause.",
        &bsd2,
        &isc_preference,
    );
    const no_endorsement = question(
        "Do you want an explicit clause prohibiting endorsement using contributors' names?",
        "BSD-3-Clause adds an explicit prohibition on using the project or contributors' names to endorse or promote derived products without permission.",
        &bsd3,
        &bsd_preference,
    );
    const source_marking = question(
        "Do you require altered source versions to be marked and their origin not misrepresented?",
        "Zlib prohibits misrepresenting origin, requires altered source versions to be plainly marked, and preserves its notice in source distributions. Acknowledgment in product documentation is appreciated but not required.",
        &zlib,
        &boost,
    );
    const omit_binary_notice = question(
        "Is preserving notices in source enough, without a binary notice-copy requirement?",
        "Boost exempts solely machine-executable distributions from its notice condition. Zlib preserves notices in source and adds origin/altered-source rules. Choose no to retain notice requirements for both source and binary copies.",
        &source_marking,
        &no_endorsement,
    );
    const waive_notice = question(
        "Do you want to waive the requirement to preserve copyright and permission notices?",
        "0BSD permits redistribution in source or binary form without requiring a copyright notice or license text to be retained.",
        &zero_bsd,
        &omit_binary_notice,
    );
    const dedicate = question(
        "Do you want to dedicate the work to the public domain?",
        "The Unlicense dedicates the work to the public domain to the extent possible and provides a fallback broad permission where that dedication is not effective.",
        &unlicense,
        &waive_notice,
    );
    const patent_grant = question(
        "Do you need an express contributor patent license?",
        "Apache-2.0 includes an express patent license from contributors, subject to its terms and patent-litigation termination provision; it also requires preservation of notices and specified NOTICE-file attributions.",
        &apache,
        &dedicate,
    );

    const gpl3_only = recommendation(.@"GPL-3.0-only");
    const gpl3_later = recommendation(.@"GPL-3.0-or-later");
    const gpl2_only = recommendation(.@"GPL-2.0-only");
    const gpl2_later = recommendation(.@"GPL-2.0-or-later");
    const agpl_only = recommendation(.@"AGPL-3.0-only");
    const agpl_later = recommendation(.@"AGPL-3.0-or-later");
    const lgpl3_only = recommendation(.@"LGPL-3.0-only");
    const lgpl3_later = recommendation(.@"LGPL-3.0-or-later");
    const lgpl21_only = recommendation(.@"LGPL-2.1-only");
    const lgpl21_later = recommendation(.@"LGPL-2.1-or-later");
    const mpl = recommendation(.@"MPL-2.0");
    const epl2 = recommendation(.@"EPL-2.0");
    const epl1 = recommendation(.@"EPL-1.0");

    const gpl3_later_choice = question(
        "Should recipients be allowed to use a later GPL version?",
        "GPL-3.0-or-later lets recipients choose GPL version 3 or a later version published by the Free Software Foundation; GPL-3.0-only does not grant that later-version permission.",
        &gpl3_later,
        &gpl3_only,
    );
    const gpl2_later_choice = question(
        "Should recipients be allowed to use a later GPL version?",
        "For an existing GPL-2.0 project, choose GPL-2.0-or-later only if the project grants permission to use later GPL versions; otherwise retain GPL-2.0-only.",
        &gpl2_later,
        &gpl2_only,
    );
    const existing_gpl2 = question(
        "Does an existing project require GPL version 2?",
        "Select version 2 only to match an existing project's licensing requirement. Do not replace third-party GPL-2.0-only terms with another version.",
        &gpl2_later_choice,
        &gpl3_later_choice,
    );
    const lgpl21_later_choice = question(
        "Should recipients be allowed to use a later LGPL version?",
        "LGPL-2.1-or-later permits later LGPL versions; LGPL-2.1-only does not. An existing library must already grant this permission, or you must own the rights to grant it.",
        &lgpl21_later,
        &lgpl21_only,
    );
    const lgpl3_later_choice = question(
        "Should recipients be allowed to use a later LGPL version?",
        "LGPL-3.0-or-later permits later LGPL versions; LGPL-3.0-only fixes the library's LGPL grant to version 3.",
        &lgpl3_later,
        &lgpl3_only,
    );
    const existing_lgpl21 = question(
        "Does an existing library require LGPL version 2.1?",
        "Select version 2.1 only to match an existing library. Its GPL conversion option is distinct from permission to upgrade to LGPL version 3.",
        &lgpl21_later_choice,
        &lgpl3_later_choice,
    );
    const existing_epl1 = question(
        "Does an existing project require EPL version 1.0?",
        "Select version 1.0 only for an existing project's explicit requirement; otherwise use EPL version 2.0.",
        &epl1,
        &epl2,
    );
    const eclipse_scope = question(
        "Does your project need the Eclipse Public License ecosystem?",
        "EPL has its own contribution, distribution, patent, and commercial-distributor obligations. It is not a generic 'business-friendly' fallback.",
        &existing_epl1,
        &unmatched_copyleft_advice,
    );
    const file_scope = question(
        "Do you want copyleft to apply file-by-file?",
        "MPL-2.0 keeps distributed covered files under MPL, while separate files in a larger work may have different licenses.",
        &mpl,
        &eclipse_scope,
    );
    const library_scope = question(
        "Do you want copyleft at the library boundary, with relinking rights for users?",
        "LGPL allows differently licensed applications to use a library if its source, notice, modification, and relinking conditions are met; copied library code cannot simply be relicensed.",
        &existing_lgpl21,
        &file_scope,
    );
    const project_scope = question(
        "Must copyleft cover the combined program, not only a library or individual files?",
        "GPL applies to covered combined works when distributed, rather than merely the individual modified files.",
        &existing_gpl2,
        &library_scope,
    );
    const agpl_later_choice = question(
        "Should recipients be allowed to use a later AGPL version?",
        "AGPL-3.0-or-later grants later AGPL-version permission; AGPL-3.0-only fixes the AGPL grant to version 3.",
        &agpl_later,
        &agpl_only,
    );
    const network_scope = question(
        "Must modified network-served versions provide corresponding source to remote users?",
        "AGPL covers project-wide copyleft and adds a source offer to users interacting remotely with modified network versions; this network clause does not require publication of every private change.",
        &agpl_later_choice,
        &project_scope,
    );
    const copyleft_scope = question(
        "Do you want source-sharing obligations for distributed modifications or modified network services?",
        "Ordinary copyleft is triggered by distribution of covered works, not private modification alone. AGPL additionally covers remote users of modified network versions. Choose yes to explore either obligation.",
        &network_scope,
        &patent_grant,
    );
    const rights = question(
        "Do you allow anyone to use, modify, and redistribute the software, including commercially?",
        "Open-source licenses grant these broad rights. If you need to reserve them, the open-source recommendations here do not fit.",
        &copyleft_scope,
        &reserved_rights_advice,
    );
    const software = question(
        "Are you licensing software that you have the right to license?",
        "Confirm ownership, contributor permissions, employer rights, and third-party obligations before choosing software terms. Content other than software or fonts is outside this tree.",
        &rights,
        &ownership_advice,
    );
    const font = question(
        "Do you allow the font to be used, embedded, modified, and redistributed?",
        "OFL permits those uses subject to its notices, Reserved Font Names, and restrictions on selling fonts by themselves. Confirm that you have the right to license the font.",
        &ofl,
        &font_advice,
    );
    return question(
        "Are you licensing a font?",
        "OFL addresses font-specific obligations. Software follows a separate path; documents and other assets are outside this tree.",
        &font,
        &software,
    );
}
