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

Also exercise the affected CLI mode. For changes to navigation, try `yes`, `no`, `back`, `reset`, and `quit`. For compatibility changes, check both a compatible combination such as `MIT, Apache-2.0` and a conflicting combination such as `GPL-3.0, OFL-1.1`.

CI builds and tests pull requests on Linux, macOS, and Windows. Formatting is checked separately on Linux.

## Code layout

| File | Responsibility |
| --- | --- |
| `src/main.zig` | Process setup, input handling, and the two CLI modes |
| `src/tree.zig` | License-selection decision tree |
| `src/compatibility.zig` | License identifiers, categories, and compatibility rules |
| `src/ui.zig` | ANSI terminal-screen rendering |
| `src/*_test.zig` | Decision-tree, compatibility, and rendering tests |
| `build.zig` | Build, run, and test steps |

Keep changes focused, follow existing Zig conventions, and let `zig fmt` handle indentation. Comments should explain non-obvious decisions rather than repeat the code.

## Adding or correcting licenses

1. For license selection, update the `Node` definitions and branches in `buildDecisionTree()` in `src/tree.zig`.
2. For compatibility, update `License`, its parsing/display/category mappings, and the compatibility rules in `src/compatibility.zig` as needed.
3. Add behavioral coverage in `src/tree_test.zig` or `src/compatibility_test.zig`. Check reachable recommendations and permitted/rejected combinations, not just enum membership.
4. Update the supported-license list in the [README](./README.md) and any affected explanations in [TREE_STRUCTURE.md](./TREE_STRUCTURE.md).
5. Include authoritative license references and explain the rule in your pull request. Compatibility can depend on license versions, exceptions, and how code is combined; avoid unsupported blanket claims.

## Submitting a pull request

- Use a descriptive [Conventional Commit](https://www.conventionalcommits.org/) message, for example `fix(compatibility): correct license pairing`.
- Push your branch to your fork and open a pull request against `main`.
- Describe the behavior changed, why it changed, and the commands/scenarios you verified.
- Update documentation when changing compiler requirements, supported licenses, commands, or user-visible behavior.

For a bug report, include the Zig version, operating system, command, input, expected result, and actual output. Use [GitHub issues](https://github.com/lucasfth/repolicense-cli/issues) for reports and questions.
