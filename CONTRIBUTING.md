# Contributing to Repolicense CLI

Bug reports, license-rule corrections, and pull requests are welcome. For usage, see the [README](./README.md).

## Getting started

Install [Zig 0.17.0](https://ziglang.org/download/), matching the version pinned in CI and `build.zig.zon`. Newer Zig releases may introduce breaking changes; use 0.17.0 for reproducible results.

Fork the repository, then clone your fork and create a branch:

```sh
git clone https://github.com/your-username/repolicense-cli.git
cd repolicense-cli
git switch -c fix/describe-your-change
zig build
```

The project uses only the Zig standard library. There are no additional packages to install.

## Run the CLI

```sh
# License-selection questions
zig build run

# Compatibility checker
zig build run -- --compat
```

The built executable is `zig-out/bin/repolicense` (`repolicense.exe` on Windows).

## Verify changes

Run the existing suite **before editing** to establish a baseline, then again after your changes:

```sh
zig build test
zig build
zig fmt --check src/
```

To format changed Zig files, use `zig fmt path/to/file.zig`.

Also exercise the affected CLI mode. For navigation, try `yes`, `no`, `back`, `reset`, and `quit`, including at a recommendation. For compatibility, check `GPL-2.0-only, Apache-2.0` (no combined-work target), `GPL-2.0-or-later, Apache-2.0` (GPL version 3 available), and `MIT, OFL-1.1` (conditional separate font assets). Reverse the input order and check that candidate statuses remain unchanged. See the [test plan](./TEST_PLAN.md) for additional boundaries.

CI builds and tests pull requests on Linux, macOS, and Windows. Formatting is checked separately on Linux.

CI installs the compiler through `.github/actions/setup-zig/action.yml`, verifies the official release SHA-256 hashes, and caches the compiler with `actions/cache@v5`. Compiler upgrades must update that action's version and platform hashes alongside `build.zig.zon`, the README, and this guide.

## Code layout

| File | Responsibility |
| --- | --- |
| `src/main.zig` | Process setup, input handling, and the two CLI modes |
| `src/tree.zig` | License-selection decision tree |
| `src/licenses.zig` | Shared canonical SPDX identifiers, categories, obligations, and license-text URLs |
| `src/compatibility.zig` | Directed combined-work assessments, conditional prerequisites, and common-target checks |
| `src/ui.zig` | ANSI terminal-screen rendering |
| `src/*_test.zig` | Decision-tree, compatibility, and rendering tests |
| `build.zig` | Build, run, and test steps |

Keep changes focused, follow existing Zig conventions, and let `zig fmt` handle indentation. Comments should explain non-obvious decisions rather than repeat the code.

## Adding or correcting licenses

1. Add a canonical SPDX tag and its category/obligations in `src/licenses.zig`. Parsing, display, SPDX links, and the CLI's supported list derive from this shared catalog; do not duplicate them.
2. Add a concrete obligation-driven path in `src/tree.zig`. Actual recommendations use typed `Node.license` metadata; advisory results leave it null. Explain distribution/network triggers, version permission, and any legacy-project requirement rather than ranking licenses as "simplest" or "business-friendly."
3. Update directed `assess()` rules in `src/compatibility.zig`. Distinguish ordinary compliance, specific conditional prerequisites, and actual combined-work conflicts. The target must satisfy **all** input licenses; original components keep their obligations. A symmetric pair result is a common-target search, not a directional relicensing verdict.
4. Add behavioral regressions in `src/tree_test.zig` / `src/compatibility_test.zig`: preference-to-license paths, permission/version boundaries, conditional combinations, and input-order independence. Avoid wording assertions, copied-metadata tests, or enum-membership checks without consumer behavior.
5. Update the [README](./README.md), [tree guide](./TREE_STRUCTURE.md), and [test plan](./TEST_PLAN.md) when affected. Include authoritative license sections in the pull request; exceptions, secondary-license notices, file/library boundaries, and GNU `-only` / `-or-later` permissions cannot be inferred from a short license name alone.

## Submitting a pull request

- Use a descriptive [Conventional Commit](https://www.conventionalcommits.org/) message, for example `fix(compatibility): correct license pairing`.
- Push your branch to your fork and open a pull request against `main`.
- Describe the behavior changed, why it changed, and the commands/scenarios you verified.
- Update documentation when changing compiler requirements, supported licenses, commands, or user-visible behavior.

For a bug report, include the Zig version, operating system, command, input, expected result, and actual output. Use [GitHub issues](https://github.com/lucasfth/repolicense-cli/issues) for reports and questions.
