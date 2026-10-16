const catalog = @import("licenses.zig");

pub const Id = enum {
    work_type,
    software,
    font,
    font_owned,
    font_existing,
    out_of_scope,
    ownership,
    owned,
    new_work,
    existing_terms,
    open_source,
    reserved_rights,
    open_source_help,
    permissive,
    mit,
    apache,
    advanced_permissive,
    bsd2,
    bsd3,
    zero_bsd,
    isc,
    boost,
    zlib,
    unlicense,
    copyleft,
    copyleft_help,
    whole_program,
    library_scope,
    file_scope,
    eclipse_scope,
    epl2,
    epl1,
    mpl,
    lgpl21_version,
    gpl3_only,
    gpl3_later,
    gpl2_only,
    gpl2_later,
    gpl2_version,
    lgpl21_only,
    lgpl21_later,
    lgpl3_only,
    lgpl3_later,
    network,
    ordinary,
    agpl_only,
    agpl_later,
    font_terms,
    font_help,
    font_mismatch,
    ofl,
};

pub const Advice = enum {
    out_of_scope,
    ownership,
    existing_terms,
    font_mismatch,
    reserved_rights,
};

pub const Choice = struct {
    label: []const u8,
    detail: []const u8,
    next: Id,
};

pub const Node = struct {
    title: []const u8,
    detail: []const u8,
    choices: []const Choice = &.{},
    license: ?catalog.License = null,
    advisory: ?Advice = null,
};

const work_choices = [_]Choice{
    .{ .label = "Software", .detail = "Applications, libraries, tools, and source code.", .next = .software },
    .{ .label = "Font", .detail = "Font files and font families have distinct OFL terms.", .next = .font },
    .{ .label = "Other asset", .detail = "Documents, data, artwork, and other non-software assets are outside this questionnaire.", .next = .out_of_scope },
};
const ownership_choices = [_]Choice{
    .{ .label = "I have the rights to license it", .detail = "You control the relevant rights or have authority from all rightsholders.", .next = .owned },
    .{ .label = "Rights are uncertain or shared", .detail = "Resolve author, employer, contributor, and third-party rights first.", .next = .ownership },
};
const font_ownership_choices = [_]Choice{
    .{ .label = "I have the rights to license it", .detail = "You control the relevant font rights or have authority from all rightsholders.", .next = .font_owned },
    .{ .label = "Rights are uncertain or shared", .detail = "Resolve author, employer, contributor, and third-party font rights first.", .next = .ownership },
};
const open_help_choices = [_]Choice{
    .{ .label = "Permissive reuse", .detail = "Broad reuse with license-specific notice and other conditions.", .next = .permissive },
    .{ .label = "Copyleft sharing", .detail = "Choose file, library, or whole-program coverage.", .next = .copyleft },
};
const copyleft_help_choices = [_]Choice{
    .{ .label = "Whole combined program", .detail = "Strong project-wide sharing obligations for distributed covered combinations.", .next = .whole_program },
    .{ .label = "Library boundary", .detail = "Keep library modifications covered while permitting separate applications under other terms, subject to relinking requirements.", .next = .library_scope },
    .{ .label = "File by file", .detail = "Keep covered files and their modifications under copyleft while separate files may use other terms.", .next = .file_scope },
    .{ .label = "Eclipse ecosystem", .detail = "Consider EPL only when its contribution and distribution model fits the project.", .next = .eclipse_scope },
};
const new_or_existing_choices = [_]Choice{
    .{ .label = "New work under my control", .detail = "Choose terms for a work whose licensing you can decide.", .next = .new_work },
    .{ .label = "Existing, forked, or community project", .detail = "Preserve grants already made and check contributor authority and compatibility; do not assume you may replace the license.", .next = .existing_terms },
};
const new_work_choices = [_]Choice{
    .{ .label = "Open-source permissions fit", .detail = "Allow use, modification, and redistribution under published terms.", .next = .open_source },
    .{ .label = "I need to reserve these rights", .detail = "Open-source licenses grant broad reuse; this tool does not draft proprietary terms.", .next = .reserved_rights },
    .{ .label = "Help me decide", .detail = "Compare common permission and sharing models before choosing.", .next = .open_source_help },
};
const permission_choices = [_]Choice{
    .{ .label = "Permissive: MIT or Apache-2.0", .detail = "Broad reuse, including proprietary derivatives; Apache adds an express contributor patent grant and NOTICE conditions.", .next = .permissive },
    .{ .label = "Copyleft: share covered changes", .detail = "Select file-, library-, or whole-program sharing obligations.", .next = .copyleft },
    .{ .label = "Help me decide", .detail = "Review what broad reuse and copyleft sharing mean before choosing a family.", .next = .open_source_help },
};
const permissive_choices = [_]Choice{
    .{ .label = "MIT", .detail = "Common concise permissive terms; retain copyright and license notices.", .next = .mit },
    .{ .label = "Apache-2.0", .detail = "Common permissive terms with express contributor patent rights and additional notice obligations.", .next = .apache },
    .{ .label = "Advanced permissive choices", .detail = "Compare BSD, ISC, 0BSD, Boost, Zlib, and public-domain dedication terms.", .next = .advanced_permissive },
};
const advanced_permissive_choices = [_]Choice{
    .{ .label = "BSD-2-Clause", .detail = "BSD ecosystem; retain source notices and reproduce them for binary distributions.", .next = .bsd2 },
    .{ .label = "BSD-3-Clause", .detail = "BSD-2-Clause terms plus an explicit no-endorsement condition.", .next = .bsd3 },
    .{ .label = "0BSD", .detail = "Permits copying and distribution without requiring attribution or license notice retention.", .next = .zero_bsd },
    .{ .label = "ISC", .detail = "Short permissive terms; retain the copyright and permission notice.", .next = .isc },
    .{ .label = "Boost Software License 1.0", .detail = "Source notice conditions; solely machine-executable object code is exempt from that condition. Not BUSL.", .next = .boost },
    .{ .label = "Zlib", .detail = "Retain notices in source, mark altered source, and do not misrepresent origin.", .next = .zlib },
    .{ .label = "Unlicense", .detail = "Public-domain dedication where possible, with a fallback permission; not the same as retaining copyright under 0BSD.", .next = .unlicense },
};
const copyleft_choices = [_]Choice{
    .{ .label = "Whole combined program", .detail = "Strong project-wide sharing obligations for distributed covered combinations.", .next = .whole_program },
    .{ .label = "Library boundary", .detail = "Keep library modifications covered while permitting separate applications under other terms, subject to relinking requirements.", .next = .library_scope },
    .{ .label = "File by file", .detail = "Keep covered files and their modifications under copyleft while separate files may use other terms.", .next = .file_scope },
    .{ .label = "Eclipse ecosystem", .detail = "Consider EPL only when its contribution and distribution model fits the project.", .next = .eclipse_scope },
    .{ .label = "Help me decide", .detail = "Compare the boundaries where source-sharing obligations apply.", .next = .copyleft_help },
};
const library_choices = [_]Choice{
    .{ .label = "LGPL-3.0-only", .detail = "Library-level copyleft with LGPL version 3 additional permissions.", .next = .lgpl3_only },
    .{ .label = "LGPL-3.0-or-later", .detail = "Allow later LGPL versions as well as version 3.", .next = .lgpl3_later },
    .{ .label = "Existing LGPL-2.1 grant", .detail = "Use version 2.1 only when rights permit that specific grant.", .next = .lgpl21_version },
};
const font_choices = [_]Choice{
    .{ .label = "Accept OFL conditions", .detail = "Fonts and derivatives stay under OFL, preserve notices, respect Reserved Font Names, and cannot be sold by themselves.", .next = .ofl },
    .{ .label = "I cannot accept all conditions", .detail = "Do not apply OFL where these obligations conflict with your requirements.", .next = .font_mismatch },
    .{ .label = "Help me decide", .detail = "Review font-specific permissions and restrictions before deciding.", .next = .font_help },
};
const font_help_choices = [_]Choice{
    .{ .label = "Accept OFL conditions", .detail = "Fonts and derivatives stay under OFL, preserve notices, respect Reserved Font Names, and cannot be sold by themselves.", .next = .ofl },
    .{ .label = "I cannot accept all conditions", .detail = "Do not apply OFL where these obligations conflict with your requirements.", .next = .font_mismatch },
};
const gpl2_choices = [_]Choice{
    .{ .label = "GPL-2.0-only", .detail = "Grant GPL version 2 only.", .next = .gpl2_only },
    .{ .label = "GPL-2.0-or-later", .detail = "Grant GPL version 2 and later versions.", .next = .gpl2_later },
};
const lgpl21_choices = [_]Choice{
    .{ .label = "LGPL-2.1-only", .detail = "Fix the grant to LGPL version 2.1.", .next = .lgpl21_only },
    .{ .label = "LGPL-2.1-or-later", .detail = "Allow later LGPL versions.", .next = .lgpl21_later },
};

pub fn node(id: Id) Node {
    return switch (id) {
        .work_type => .{ .title = "What are you licensing?", .detail = "Start with the kind of work; font and software rights follow separate paths.", .choices = &work_choices },
        .software => .{ .title = "Who can authorize licensing this software?", .detail = "Ownership and authority are independent of which license obligations you prefer.", .choices = &ownership_choices },
        .font => .{ .title = "Who can authorize licensing this font?", .detail = "Confirm rights in the font files and contributions before selecting terms.", .choices = &font_ownership_choices },
        .out_of_scope => .{ .title = "This asset is outside the questionnaire", .detail = "The software and font recommendations here do not assess licenses for documents, datasets, artwork, or other assets.", .advisory = .out_of_scope },
        .ownership => .{ .title = "Resolve ownership and authority first", .detail = "Identify authors, employers, contributors, and third-party components. Obtain the required permission before choosing terms.", .advisory = .ownership },
        .owned => .{ .title = "Is this new work or an existing project?", .detail = "For existing projects, forks, and communities, preserve existing grants and check compatibility rather than assuming unilateral relicensing authority.", .choices = &new_or_existing_choices },
        .font_owned => .{ .title = "Is this an existing font project?", .detail = "Preserve existing font grants and Reserved Font Name rules; do not assume you may replace community or contributor terms.", .choices = &.{
            .{ .label = "New font under my control", .detail = "Choose font terms for work whose licensing you control.", .next = .font_terms },
            .{ .label = "Existing, forked, or community font", .detail = "Preserve existing grants and verify authority before changing terms.", .next = .font_existing },
        } },
        .font_existing => .{ .title = "Preserve the font project's existing terms", .detail = "Review the existing license, Reserved Font Names, contributor permissions, and compatibility. Do not assume you can relicense a community font.", .advisory = .existing_terms },
        .new_work => .{ .title = "Do broad open-source permissions fit?", .detail = "Open source allows anyone to use, modify, and redistribute the work, including commercially. Copyleft can require source sharing; it cannot prohibit commercial use or competitors.", .choices = &new_work_choices },
        .existing_terms => .{ .title = "Preserve the project's existing terms", .detail = "Review the current license grants, contributor agreements, provenance, and compatibility with dependencies. Do not upgrade versions or relicense without authority from the relevant rightsholders.", .advisory = .existing_terms },
        .open_source => .{ .title = "Choose the permission and sharing model", .detail = "Permissive licenses allow broad reuse subject to their conditions; copyleft licenses impose source-sharing obligations on covered distributions or services.", .choices = &permission_choices },
        .reserved_rights => .{ .title = "Open-source permissions do not match", .detail = "Open-source licenses grant use, modification, and redistribution rights. Review proprietary or specialized terms with qualified counsel; this tool does not draft or recommend them.", .advisory = .reserved_rights },
        .open_source_help => .{ .title = "Compare open-source licensing models", .detail = "Permissive terms such as MIT allow proprietary derivatives while requiring notices. Apache-2.0 also supplies an express contributor patent grant and NOTICE conditions. Copyleft terms require covered modifications or combinations to remain under specified terms when distributed; AGPL adds a source offer for modified network versions. Choose a model below.", .choices = &open_help_choices },
        .permissive => .{ .title = "Choose permissive terms", .detail = "MIT is a common concise choice; Apache-2.0 adds express patent rights and additional notice conditions. Advanced options have distinct notice or attribution rules.", .choices = &permissive_choices },
        .mit => outcome(.MIT, "MIT fits a common goal of broad reuse with a simple requirement to retain copyright and license notices."),
        .apache => outcome(.@"Apache-2.0", "Apache-2.0 fits broad reuse when an express contributor patent grant and its NOTICE and change-marking conditions are desired."),
        .advanced_permissive => .{ .title = "Choose an advanced permissive license", .detail = "These are not interchangeable defaults: compare notice retention, endorsement, source marking, patent terms, and public-domain dedication before selecting.", .choices = &advanced_permissive_choices },
        .bsd2 => outcome(.@"BSD-2-Clause", "BSD-2-Clause fits a BSD ecosystem when its source and binary notice conditions are acceptable."),
        .bsd3 => outcome(.@"BSD-3-Clause", "BSD-3-Clause fits when BSD notice conditions and an explicit no-endorsement term are desired."),
        .zero_bsd => outcome(.@"0BSD", "0BSD fits when redistribution should not require retaining attribution or license notices."),
        .isc => outcome(.ISC, "ISC fits when short permissive terms and retention of its copyright and permission notice are desired."),
        .boost => outcome(.@"BSL-1.0", "Boost Software License 1.0 fits when its source notice conditions and machine-executable distribution exception are suitable."),
        .zlib => outcome(.Zlib, "Zlib fits when preserving source notices, marking altered source, and avoiding origin misrepresentation are suitable."),
        .unlicense => outcome(.Unlicense, "The Unlicense fits a public-domain dedication goal, subject to local enforceability and third-party rights."),
        .copyleft => .{ .title = "Where should copyleft obligations apply?", .detail = "File-level rules cover distributed modified files; library-level rules preserve a library boundary with relinking rights; whole-program rules cover distributed combined works. Network source obligations are asked only for the whole-program path.", .choices = &copyleft_choices },
        .copyleft_help => .{ .title = "Compare copyleft boundaries", .detail = "MPL applies to covered files, allowing separate files under other terms. LGPL applies at a library boundary and requires users' ability to modify/relink the library under its conditions. GPL covers distributed combined programs. AGPL adds a source offer to remote users of a modified network version. Choose the scope that matches your intended architecture.", .choices = &copyleft_help_choices },
        .whole_program => .{ .title = "Should remote users of modified network versions receive source?", .detail = "AGPL adds a source offer to remote users of modified network versions. Choose it when you want this additional obligation; serving software over a network alone does not require AGPL.", .choices = &.{
            .{ .label = "Yes", .detail = "Include the network source offer; continue to the AGPL version grant.", .next = .network },
            .{ .label = "No", .detail = "Use ordinary distribution copyleft; continue to GPL version and grant choices.", .next = .ordinary },
        } },
        .library_scope => .{ .title = "Choose library copyleft terms", .detail = "LGPL permits separately licensed applications under conditions including notices, source access, and relinking. It does not allow copied library code to be relicensed. Use the 2.1 route only with authority to grant it.", .choices = &library_choices },
        .file_scope => .{ .title = "Choose file-level copyleft", .detail = "MPL-2.0 keeps covered distributed files and modifications under MPL while separate files may use other licenses.", .choices = &.{.{ .label = "MPL-2.0", .detail = "Select file-level copyleft terms.", .next = .mpl }} },
        .eclipse_scope => .{ .title = "Choose EPL only for an Eclipse-project fit", .detail = "EPL has its own contribution, patent, distribution, and commercial-distributor conditions. EPL-1.0 should be selected only to preserve an existing explicit requirement.", .choices = &.{
            .{ .label = "EPL-2.0", .detail = "Use the current EPL version when the Eclipse ecosystem is required.", .next = .epl2 },
            .{ .label = "Existing EPL-1.0 project requirement", .detail = "Preserve version 1.0 only where existing rights and project terms require it.", .next = .epl1 },
        } },
        .epl2 => outcome(.@"EPL-2.0", "EPL-2.0 fits a project that specifically needs the Eclipse ecosystem and accepts its distinct conditions."),
        .epl1 => outcome(.@"EPL-1.0", "EPL-1.0 fits only an existing project requirement that authorizes that version."),
        .mpl => outcome(.@"MPL-2.0", "MPL-2.0 fits a file-level sharing goal: covered files remain under MPL while separate files may use other terms."),
        .lgpl21_version => .{ .title = "Select the LGPL-2.1 grant", .detail = "Choose an LGPL-2.1 variant only if you hold authority to grant those terms; later LGPL versions are not implied by LGPL-2.1-only.", .choices = &lgpl21_choices },
        .gpl2_version => .{ .title = "Select the GPL-2.0 grant", .detail = "For new code with a specific GPL-2.0 compatibility requirement, choose the grant you are authorized to make. This cannot change an existing component's permissions.", .choices = &gpl2_choices },
        .gpl3_only => outcome(.@"GPL-3.0-only", "GPL-3.0-only fits whole-program copyleft when the grant should remain fixed to version 3."),
        .gpl3_later => outcome(.@"GPL-3.0-or-later", "GPL-3.0-or-later fits whole-program copyleft when recipients may use later GPL versions."),
        .gpl2_only => outcome(.@"GPL-2.0-only", "GPL-2.0-only fits only a project with authority and a specific reason to grant version 2 alone."),
        .gpl2_later => outcome(.@"GPL-2.0-or-later", "GPL-2.0-or-later fits only a project with authority to grant version 2 and later versions."),
        .lgpl21_only => outcome(.@"LGPL-2.1-only", "LGPL-2.1-only fits a library when version 2.1 is the authorized grant; its GPL conversion option is not an LGPL upgrade."),
        .lgpl21_later => outcome(.@"LGPL-2.1-or-later", "LGPL-2.1-or-later fits a library when the rightsholders authorize later LGPL versions."),
        .lgpl3_only => outcome(.@"LGPL-3.0-only", "LGPL-3.0-only fits library-level sharing when the grant is fixed to version 3."),
        .lgpl3_later => outcome(.@"LGPL-3.0-or-later", "LGPL-3.0-or-later fits library-level sharing when recipients may use later LGPL versions."),
        .network => .{ .title = "Select an AGPL version grant", .detail = "AGPL adds a source offer to remote users of modified network versions. Choose whether the authorized grant permits later AGPL versions.", .choices = &.{
            .{ .label = "AGPL-3.0-only", .detail = "Fix the grant to AGPL version 3.", .next = .agpl_only },
            .{ .label = "AGPL-3.0-or-later", .detail = "Allow later AGPL versions.", .next = .agpl_later },
        } },
        .ordinary => .{ .title = "Select a GPL version grant", .detail = "GPL requires sharing covered distributed combined works. Version 2 is included only as an explicit compatibility choice, not an automatic upgrade or default.", .choices = &.{
            .{ .label = "GPL-3.0-only", .detail = "Fix the grant to GPL version 3.", .next = .gpl3_only },
            .{ .label = "GPL-3.0-or-later", .detail = "Allow later GPL versions.", .next = .gpl3_later },
            .{ .label = "GPL-2.0 compatibility requirement", .detail = "Choose version 2 for a specific compatibility requirement when you control the grant.", .next = .gpl2_version },
        } },
        .agpl_only => outcome(.@"AGPL-3.0-only", "AGPL-3.0-only fits whole-program copyleft when its network source offer is intended and the grant is fixed to version 3."),
        .agpl_later => outcome(.@"AGPL-3.0-or-later", "AGPL-3.0-or-later fits whole-program copyleft when its network source offer is intended and later AGPL versions are permitted."),
        .font_terms => .{ .title = "Can you accept OFL's font conditions?", .detail = "OFL requires font and derivative redistribution under OFL, retention of notices, respect for Reserved Font Names, and prohibits selling the font by itself. Documents made with the font are not thereby covered.", .choices = &font_choices },
        .font_help => .{ .title = "Review OFL font conditions", .detail = "OFL permits using, embedding, modifying, and redistributing fonts. Font files and derivatives stay under OFL; preserve notices, respect Reserved Font Names, and do not sell fonts by themselves. Choose only if those conditions fit.", .choices = &font_help_choices },
        .font_mismatch => .{ .title = "OFL conditions do not fit", .detail = "Do not use OFL if its same-license font terms, notices, Reserved Font Name rules, or standalone-sale restriction conflict with your needs. Review existing font rights or seek font-specific guidance.", .advisory = .font_mismatch },
        .ofl => outcome(.@"OFL-1.1", "OFL-1.1 fits font use and redistribution when the font-specific same-license, notice, Reserved Font Name, and standalone-sale conditions are accepted."),
    };
}

fn outcome(license: catalog.License, detail: []const u8) Node {
    return .{ .title = license.toString(), .detail = detail, .license = license };
}
