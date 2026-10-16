<h1 align="center">Repolicense CLI</h1>

<p align="center">
  Choose an open-source license. Check compatibility before combining code.
</p>

<p align="center">
  <a href="https://ziglang.org/download/">
    <img alt="Zig 0.17.0" src="https://img.shields.io/badge/Zig-0.17.0-F7A41D?logo=zig&amp;logoColor=white">
  </a>
  <a href="./LICENSE">
    <img alt="License: Apache-2.0" src="https://img.shields.io/badge/License-Apache--2.0-blue">
  </a>
  <a href="https://github.com/lucasfth/repolicense-cli/actions/workflows/ci.yml">
    <img alt="CI build and test status" src="https://img.shields.io/github/actions/workflow/status/lucasfth/repolicense-cli/ci.yml?branch=main&amp;label=CI&amp;logo=github">
  </a>
</p>

<p align="center">
  <a href="https://github.com/lucasfth/repolicense-cli/issues">
    <img alt="Open GitHub issues" src="https://img.shields.io/github/issues/lucasfth/repolicense-cli">
  </a>
  <a href="https://github.com/lucasfth/repolicense-cli/pulls">
    <img alt="Open GitHub pull requests" src="https://img.shields.io/github/issues-pr/lucasfth/repolicense-cli">
  </a>
</p>

<p align="center">
  <a href="#getting-started">Get started</a> ·
  <a href="#usage">Usage</a> ·
  <a href="./CONTRIBUTING.md">Contribute</a> ·
  <a href="https://github.com/lucasfth/repolicense-cli/issues">Report an issue</a>
</p>

---

A terminal companion to [repolicense](https://github.com/lucasfth/repolicense), built with Zig and its standard library. Answer a series of questions to explore licenses for your project, or enter existing licenses to check the compatibility rules for combining code.

- **License selection** — intent-based software/font menus, ownership checks, and explained recommendations.
- **Navigation** — go back to an earlier question or restart the session.
- **Compatibility checks** — supported and conditional combined-work targets, with explicit GNU versions.
- **Local operation** — no account, service, or required runtime dependency. Optional [Gum](https://github.com/charmbracelet/gum) adds terminal menus; the CLI never downloads it or makes API calls.

> This tool offers general guidance, not legal advice. Review the actual license terms and your project's obligations before choosing a license or combining code.

## Contents

- [Getting started](#getting-started)
- [Usage](#usage)
- [Supported licenses](#supported-licenses)
- [Development](#development)
- [Contributing](#contributing)
- [License and acknowledgments](#license-and-acknowledgments)

## Getting started

Install [Zig 0.17.0](https://ziglang.org/download/), the version used by CI. Zig is still pre-1.0; newer compiler releases may require source changes.

```sh
git clone https://github.com/lucasfth/repolicense-cli.git
cd repolicense-cli
zig build
./zig-out/bin/repolicense
```

On Windows, the executable is `zig-out/bin/repolicense.exe`.

To build and run in one step:

```sh
zig build run
```

### Install the terminal command

On macOS or Linux, install a release build under your user prefix:

```sh
zig build -Doptimize=ReleaseSafe --prefix "$HOME/.local"
repolicense
```

Ensure `$HOME/.local/bin` is on your shell's `PATH`. Repeat the build command after pulling updates to refresh the installed executable.

## Usage

### Choose a license

Start without arguments to open a menu: **Choose a license**, **Check compatibility**, or **Quit**. Select Choose a license, then software, font, or another asset, confirm licensing authority, and establish whether existing project terms constrain the choice. Existing/forked/community projects receive guidance to preserve their grants rather than a fresh license recommendation. Other assets get an explicit out-of-scope result.

For new software, select broad open-source permissions and then permissive or copyleft goals. The common MIT/Apache path takes six selections. Specialist permissive licenses remain under advanced choices. Copyleft offers file, library, whole-program, and Eclipse-specific choices; only whole-program sharing asks about the additional AGPL network source offer. GNU version grants are explicit. Fonts require accepting OFL's same-license, notice, naming, and standalone-sale conditions.

Every recommendation explains why it fits, its obligations and limitations, and links to the SPDX text. Back/restart remain available at recommendations and advisory outcomes.

### Optional terminal menus

Install Gum separately if desired, for example `brew install gum` on macOS or `winget install charmbracelet.gum` on Windows. See [Gum installation](https://github.com/charmbracelet/gum#installation) for other platforms. It is not a build requirement.

When `gum` is on `PATH`, all three standard streams are terminals, and `TERM` is not `dumb`, the CLI uses a styled header, rounded question/guidance/result panels, and highlighted arrow-key menus. Enter confirms a choice. Compatibility mode uses a styled introduction/results heading and searchable multi-select picker: type to search, Tab toggles and advances, Enter checks the selection, and Ctrl-C cancels. Gum renders its own menus; Repolicense replaces the viewport between questionnaire steps rather than guessing frame line counts. Styling and terminal behavior were exercised with Gum 2.0.2.

Use `repolicense --plain` or `repolicense --compat --plain` to force plain mode. Missing Gum falls back automatically; redirected streams always use plain output without ANSI escapes. Gum's own exit status 1 can mean either cancellation or a runtime error: its diagnostics remain visible and no recommendation is inferred from that exit.

Interactive questionnaire navigation replaces the previous view, including in numbered mode without Gum. Back and Restart clear the old question rather than adding another copy below it. Redirected streams and `TERM=dumb` retain a readable transcript instead. In Gum menus, Back is an explicit action; Esc/Ctrl-C cancels the session rather than selecting Back.

| Plain input | Action |
| --- | --- |
| Number or displayed label | Select an option |
| `y` / `n` | Select a literal Yes / No option, where offered |
| `back` or `b` | Return to the previous question |
| `reset`, `restart`, or `r` | Start again |
| `quit`, `q`, or `exit` | End the session |

`--help` / `-h` shows usage. Unknown arguments exit with status 2.

### Check compatibility

Choose **Check compatibility** from the start menu, or use `--compat` / `-c` to skip it. Gum results open a compact overview: selected identifiers, whether supported common targets exist, and ordinary/conditional target counts. Ordinary targets still require standard license compliance; conditional targets have additional prerequisites. **View targets and conditions** opens the full scrollable assessment, including pairwise checks; `q` returns to the overview. **Check another combination** reopens selection; **Quit** exits. Plain mode prints the full assessment directly.

```sh
zig build run -- --compat
```

Or run the built executable with `--compat` (short form: `-c`):

```sh
./zig-out/bin/repolicense --compat
```

At the prompt, enter canonical SPDX identifiers separated by commas:

```text
BSL-1.0, Zlib, Apache-2.0
GPL-2.0-or-later, Apache-2.0
```

Identifiers are case-insensitive; duplicate entries are ignored. GNU licenses require an explicit `-only` or `-or-later` suffix. Bare identifiers such as `GPL-3.0` are rejected instead of guessing which rights were granted. Enter another list to check a different combination, or `quit` / `q` to leave.

The checker evaluates a **covered combined work**, not whether independently licensed projects can share a repository:

| Result | Meaning |
| --- | --- |
| `compatible` | A supported target is available, subject to ordinary license compliance and retained component obligations. |
| `conditional` | A target requires the stated conditions, such as separate LGPL libraries, eligible MPL secondary licensing, an EPL secondary-license notice, or separately licensed font assets. |
| `incompatible` | No supported common target satisfies the inputs under this model; independent aggregation or separately granted permissions may still be possible. |

For example, `GPL-2.0-only, Apache-2.0` has no combined-program target here, while `GPL-2.0-or-later, Apache-2.0` can use GPL version 3. A GPL/AGPL version-3 combination is conditional under section 13: the modules retain their respective licenses, not blanket AGPL relicensing.

Pairwise results report the existence of a common target and do not depend on input order. They do **not** mean that either component can simply be relicensed as the other. All inputs constrain the candidate list, and original notices, source obligations, and font/library terms remain in force.

## Supported licenses

| Category | Identifiers |
| --- | --- |
| Permissive | `MIT`, `BSD-2-Clause`, `BSD-3-Clause`, `Apache-2.0`, `0BSD`, `ISC`, `BSL-1.0`, `Zlib` |
| Strong copyleft | `GPL-2.0-only`, `GPL-2.0-or-later`, `GPL-3.0-only`, `GPL-3.0-or-later`, `AGPL-3.0-only`, `AGPL-3.0-or-later` |
| Weak copyleft | `LGPL-2.1-only`, `LGPL-2.1-or-later`, `LGPL-3.0-only`, `LGPL-3.0-or-later`, `MPL-2.0`, `EPL-1.0`, `EPL-2.0` |
| Public-domain dedication | `Unlicense` |
| Fonts | `OFL-1.1` |

The shared catalog contains 23 identifiers used by both modes. `BSL-1.0` is the **Boost Software License**, not the Business Source License. `0BSD` retains copyright without a notice-copy condition; `Unlicense` is a public-domain dedication with a fallback permission.

The checker does not parse `OR` / `AND` expressions, exceptions, unlisted versions, or jurisdiction-specific issues. License names alone cannot establish how source is combined or whether a secondary-license grant exists; inspect every conditional prerequisite. Documentation and other non-font assets are outside the decision tree.

## Development

```sh
zig build test
zig fmt --check src/
```

The tests cover recommendation reachability, scope and authority boundaries, explicit version grants, canonical license parsing, order-independent compatibility, and menu input boundaries. Exercise the actual CLI with and without Gum as described in the [test plan](./TEST_PLAN.md), not just the unit suite. [CI](https://github.com/lucasfth/repolicense-cli/actions/workflows/ci.yml) builds and tests on Linux, macOS, and Windows using Zig 0.17.0, with a separate formatting check.

For the decision-tree layout and project background, see [Tree structure](./TREE_STRUCTURE.md) and [Web/CLI comparison](./COMPARISON.md).

## Contributing

Read the [contribution guide](./CONTRIBUTING.md) for setup and license additions. Bug reports and proposed improvements belong in [GitHub issues](https://github.com/lucasfth/repolicense-cli/issues); code changes are welcome through pull requests.

## License and acknowledgments

Licensed under [Apache License 2.0](./LICENSE).

The CLI originated from the [repolicense web application](https://github.com/lucasfth/repolicense); its current obligation-driven tree intentionally extends and revises that original logic.
