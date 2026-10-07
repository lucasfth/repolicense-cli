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

- **License selection** — separate font/software paths, concrete obligations, and explained recommendations.
- **Navigation** — go back to an earlier question or reset the session.
- **Compatibility checks** — supported and conditional combined-work targets, with explicit GNU versions.
- **Local operation** — no account, service, or runtime dependency; the CLI provides links rather than making API calls.

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

Start without arguments. Fonts are routed first; software questions then cover licensing rights, patent grants, notices, and the scope of copyleft. Older GNU/EPL versions are offered for existing-project requirements, not as arbitrary fallbacks. Every recommendation includes its obligations and a link to the SPDX license text.

You can revisit answers at any point, including after reaching a recommendation. A preference outside the supported choices produces guidance rather than a misleading license recommendation.

| Input | Action |
| --- | --- |
| `yes` or `y` | Answer yes |
| `no` or `n` | Answer no |
| `back` or `b` | Return to the previous question |
| `reset` or `r` | Start again |
| `quit`, `q`, or `exit` | End the session |

### Check compatibility

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

The tests cover every recommendation/advisory path, graph navigation invariants, canonical license parsing, version/obligation boundaries, order-independent compatibility, and terminal-screen rendering. Exercise the actual CLI as described in the [test plan](./TEST_PLAN.md), not just the unit suite. [CI](https://github.com/lucasfth/repolicense-cli/actions/workflows/ci.yml) builds and tests on Linux, macOS, and Windows using Zig 0.17.0, with a separate formatting check.

For the decision-tree layout and project background, see [Tree structure](./TREE_STRUCTURE.md) and [Web/CLI comparison](./COMPARISON.md).

## Contributing

Read the [contribution guide](./CONTRIBUTING.md) for setup and license additions. Bug reports and proposed improvements belong in [GitHub issues](https://github.com/lucasfth/repolicense-cli/issues); code changes are welcome through pull requests.

## License and acknowledgments

Licensed under [Apache License 2.0](./LICENSE).

The CLI originated from the [repolicense web application](https://github.com/lucasfth/repolicense); its current obligation-driven tree intentionally extends and revises that original logic.
