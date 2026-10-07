# Web and CLI comparison

Repolicense CLI originated as a terminal port of the [repolicense web application](https://github.com/lucasfth/repolicense). The CLI now has an intentionally revised obligation-driven decision tree; it is not a promise of identical questions or paths in both applications.

## Interface and architecture

| Area | Original web application | Current CLI |
| --- | --- | --- |
| Interaction | Browser yes/no controls | Terminal answers, `back`, `reset`, and `quit` |
| State | Browser session storage | In-memory session history |
| License details | GitHub API integration | Local explanations and SPDX license-text links; no network calls |
| Implementation | JavaScript, HTML/CSS, Shoelace | Zig 0.17.0 and the standard library |
| Tree representation | JavaScript objects | Static typed nodes with canonical license metadata |
| Compatibility | Not part of the original port's web interface | `--compat` / `-c`, all-input target assessment and conditional prerequisites |
| Distribution | Browser application | Native executable; Linux, macOS, and Windows CI |

## Intentional decision-tree changes

The [current tree](./TREE_STRUCTURE.md) separates fonts from software immediately, checks software licensing rights, and distinguishes concrete patent/notice obligations before recommending a permissive license. Copyleft paths distinguish combined programs, library boundaries, files, and modified network services instead of ranking licenses by vague strength or business friendliness.

GNU recommendations explicitly choose `-only` or `-or-later`; older GPL, LGPL, and EPL versions require an existing-project reason. Boost and Zlib add meaningful binary-notice/origin distinctions. Every real recommendation carries obligations and an SPDX link, while preferences outside the supported model produce guidance without a fake license link.

Both CLI modes use `src/licenses.zig`. Compatibility results preserve original component obligations and distinguish conditional library/file/font/module combinations from unconditional permission to relicense. The supported catalog and limitations are documented in the [README](./README.md).

## Choosing an interface

Use the web application for clickable navigation and its browser-oriented presentation. Use the CLI for offline guidance, terminal/SSH workflows, and its explicit combined-work compatibility model. The CLI remains interactive text output, not a stable machine-readable API; scripts should not treat presentation wording as a contract.
