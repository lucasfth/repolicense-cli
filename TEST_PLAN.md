# Verification plan

Use Zig 0.17.0. Establish a baseline before editing, then repeat the suite and exercise the real CLI after changing behavior:

```sh
zig build test --summary all
zig build
zig fmt --check src/
```

## Automated behavior coverage

- `src/tree_test.zig`: concrete preference paths for all 23 canonical recommendations and four advisory outcomes; complete question branches, terminal leaves, recommendation reachability, and cycle detection.
- `src/compatibility_test.zig`: canonical/case-insensitive parsing, rejection of ambiguous GNU IDs and compound expressions, GNU version and conversion boundaries, patent conflicts, conditional file/library/font treatment, all-input candidate intersection, and input-order invariance.
- `src/ui_test.zig`: terminal block replacement/clearing behavior.

Keep tests about consumer-visible outcomes and invariants. Do not assert question wording, copied descriptions, enum existence, or incidental formatting. Add a failing regression before fixing a boundary; a successful compile is not proof of interactive behavior.

## Decision-tree smoke

Run `./zig-out/bin/repolicense` (use `.exe` on Windows). Follow the [tree diagram](./TREE_STRUCTURE.md), checking:

- The first font path reaches OFL without traversing software preferences.
- Software ownership/reserved-rights answers produce **guidance**, not a fake license or license-text link.
- The patent-grant branch reaches Apache before the other permissive choices.
- Source-only notice preservation routes to Boost or Zlib according to altered-source/origin requirements; retaining binary-copy notices routes to MIT/BSD/ISC.
- Project/library/file copyleft reaches GPL/LGPL/MPL respectively; AGPL explicitly covers modified network versions.
- GPL-2.0, LGPL-2.1, and EPL-1.0 require an existing-project reason; GNU leaves explicitly select `-only` or `-or-later`.
- Every real recommendation shows its canonical ID, meaningful obligations, and an SPDX license-text URL.
- Unmatched copyleft preferences produce guidance rather than an unrelated fallback.

Verify navigation before and after a result: `back`, `reset`, uppercase/short answers, invalid input, and `quit`. Back at the root should stay at the root. Advisory leaves must support the same navigation as recommendations.

## Compatibility smoke

Run `./zig-out/bin/repolicense --compat`, enter each row, then repeat with its input order reversed:

| Inputs | Expected observable result |
| --- | --- |
| `BSL-1.0, Zlib` | Parsed; GPL-2.0-only is a compatible common target. |
| `GPL-2.0-only, Apache-2.0` | No combined-work target; pair incompatible. |
| `GPL-2.0-or-later, Apache-2.0` | GPL-3.0-only available. |
| `GPL-2.0-only, GPL-3.0-only` | No combined-work target. |
| `GPL-2.0-only, LGPL-3.0-or-later` | No combined-work target; later LGPL permission does not make GPL version 2 compatible. |
| `GPL-3.0-only, AGPL-3.0-only` | Conditional AGPL target; retain separate module licenses under section 13. |
| `MIT, LGPL-2.1-only` | MIT is conditional for the surrounding application; keep LGPL library source/relinking obligations. |
| `MIT, MPL-2.0` | MIT is conditional for separate files; MPL-covered files remain MPL. |
| `GPL-3.0-only, EPL-2.0` | GPL target conditional on an explicit initial-contributor secondary-license notice and separate files. |
| `GPL-3.0-only, EPL-1.0` | No combined-work target without additional permissions. |
| `MIT, OFL-1.1` | MIT conditional for software with separately OFL-licensed font assets; OFL is not a target software license. |

Also verify:

- `GPL-3.0` is rejected with an explanation requiring `-only` or `-or-later`.
- `mit, bsl-1.0, MIT, ZLIB` displays canonical identifiers and removes the duplicate MIT entry.
- Unsupported `OR` / `AND` expressions are rejected instead of being guessed.
- `-c` starts the same checker; another input can be checked in the same session; `quit` ends it.
- Conditional rows list the prerequisites for **every** conditional source, rather than asserting unconditional relicensing.
- Empty input prompts again; EOF exits cleanly.

## Installed command and platforms

On macOS/Linux, refresh the installed command after a source update:

```sh
zig build -Doptimize=ReleaseSafe --prefix "$HOME/.local"
repolicense
repolicense --compat
```

Ensure `$HOME/.local/bin` is on `PATH` or that your configured shell alias resolves to the current build. CI compiles and runs tests on Linux, macOS, and Windows; also inspect interactive clearing in a real terminal when changing `src/ui.zig`.
