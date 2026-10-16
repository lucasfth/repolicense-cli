# Web and CLI comparison

Repolicense CLI originated as a terminal port of the [repolicense web application](https://github.com/lucasfth/repolicense). The CLI now has an intentionally revised obligation-driven decision tree; it is not a promise of identical questions or paths in both applications.

## Interface and architecture

| Area | Original web application | Current CLI |
| --- | --- | --- |
| Interaction | Browser yes/no controls | Optional Gum menus or standalone numbered/label prompts; back/restart/quit |
| State | Browser session storage | In-memory session history |
| License details | GitHub API integration | Local explanations and SPDX license-text links; no network calls |
| Implementation | JavaScript, HTML/CSS, Shoelace | Zig 0.17.0 and standard library; optional external Gum executable |
| Tree representation | JavaScript objects | Static typed menu graph with canonical license metadata |
| Compatibility | Not part of the original port's web interface | `--compat` / `-c`, all-input target assessment and conditional prerequisites |
| Distribution | Browser application | Native executable; Linux, macOS, and Windows CI |

## Intentional decision-tree changes

The [current graph](./TREE_STRUCTURE.md) separates software, fonts, and unsupported assets; checks authority independently; and handles existing project constraints before new-work preferences. The common MIT/Apache path takes six selections rather than a sequence of specialist yes/no questions. Advanced permissive choices retain the BSD/ISC/0BSD/Boost/Zlib/Unlicense distinctions.

Copyleft choices distinguish combined programs, library boundaries, and files. AGPL's network source offer is an explicit goal, not a consequence of merely running a server. GNU grants explicitly choose `-only` or `-or-later`; legacy versions require a specific authorized reason. Fonts require accepting OFL-specific conditions. Every recommendation carries a rationale, obligations, and an SPDX link; unsupported goals produce typed guidance without a fake license link.

Both CLI modes use `src/licenses.zig`. Compatibility results preserve original component obligations and distinguish conditional library/file/font/module combinations from unconditional permission to relicense. The supported catalog and limitations are documented in the [README](./README.md).

## Choosing an interface

Use the web application for clickable navigation and its browser-oriented presentation. Use the CLI for offline guidance, terminal/SSH workflows, and its explicit combined-work compatibility model. The CLI remains interactive text output, not a stable machine-readable API; scripts should not treat presentation wording as a contract.
