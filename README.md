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

- **License selection** — a yes/no decision tree with explanations and links to license details.
- **Navigation** — go back to an earlier question or reset the session.
- **Compatibility checks** — compare comma-separated licenses and see the reasons behind each pairing.
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

Start without arguments and answer the questions about your project. You can revisit answers at any point, including after reaching a recommendation.

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

At the prompt, enter SPDX-style identifiers separated by commas:

```text
MIT, Apache-2.0
```

The checker lists the licenses its rules permit for the combined work and explains pairwise compatibility. License identifiers are case-insensitive. Enter another list to check a different combination, or `quit` / `q` to leave.

## Supported licenses

| Category | Identifiers |
| --- | --- |
| Permissive | `MIT`, `BSD-2-Clause`, `BSD-3-Clause`, `Apache-2.0`, `0BSD`, `ISC` |
| Strong copyleft | `GPL-2.0`, `GPL-3.0`, `AGPL-3.0` |
| Weak copyleft | `LGPL-3.0`, `MPL-2.0`, `EPL-1.0`, `EPL-2.0` |
| Public-domain dedication | `Unlicense` |
| Fonts | `OFL-1.1` |

These are the identifiers understood by the CLI; the checker does not model every license exception or variant.

## Development

```sh
zig build test
zig fmt --check src/
```

The existing tests cover decision-tree paths, license parsing and compatibility rules, and terminal-screen rendering. [CI](https://github.com/lucasfth/repolicense-cli/actions/workflows/ci.yml) builds and tests on Linux, macOS, and Windows using Zig 0.17.0, with a separate formatting check.

For the decision-tree layout and project background, see [Tree structure](./TREE_STRUCTURE.md) and [Web/CLI comparison](./COMPARISON.md).

## Contributing

Read the [contribution guide](./CONTRIBUTING.md) for setup and license additions. Bug reports and proposed improvements belong in [GitHub issues](https://github.com/lucasfth/repolicense-cli/issues); code changes are welcome through pull requests.

## License and acknowledgments

Licensed under [Apache License 2.0](./LICENSE).

The decision tree is based on the original [repolicense web application](https://github.com/lucasfth/repolicense).
