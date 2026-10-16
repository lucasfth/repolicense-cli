# Verification plan

Use Zig 0.17.0. Establish a baseline before editing, then repeat the suite and exercise the real CLI after changing behavior:

```sh
zig build test --summary all
zig build
zig fmt --check src/
```

## Automated behavior coverage

- `src/tree_test.zig`: all 23 recommendation outcomes reachable, graph cycles and terminal-leaf invariants, distinct authority/scope/existing/font outcomes, common-path length, copyleft boundaries, and explicit GNU grants.
- `src/compatibility_test.zig`: canonical/case-insensitive parsing, rejection of ambiguous GNU IDs and compound expressions, GNU version and conversion boundaries, patent conflicts, conditional file/library/font treatment, all-input candidate intersection, and input-order invariance.
- `src/ui_test.zig`: numbered/label selection, navigation aliases, conditional yes/no aliases, multi-selection deduplication, and invalid input/buffer boundaries.

Keep tests about consumer-visible outcomes and invariants. Do not assert question wording, copied descriptions, enum existence, or incidental formatting. Add a failing regression before fixing a boundary; a successful compile is not proof of interactive behavior.

## Questionnaire smoke

Run `./zig-out/bin/repolicense --plain` (use `.exe` on Windows). Follow the [graph](./TREE_STRUCTURE.md), checking:

- Other assets exit to out-of-scope guidance; uncertain software/font authority exits to ownership guidance.
- Existing/forked/community projects preserve existing terms rather than receiving a replacement license.
- New software reaches MIT or Apache after six selections. Advanced permissives remain available with their distinct conditions.
- File/library/whole-program copyleft reaches MPL/LGPL/GPL. The whole-program network source-offer preference reaches AGPL; a server alone does not imply AGPL.
- Legacy GNU/EPL choices require a specific authorized reason; GNU grants explicitly select `-only` or `-or-later`.
- Font conditions are explicitly accepted or rejected; help explains them before accepting/refusing.
- Recommendations display canonical ID, rationale, obligations/limitations, and SPDX URL. Advisory outcomes have no license link.
- Numbers and labels work; invalid/blank input retries; back/restart/quit work before and after results. Back at the root stays there. EOF exits cleanly at root, in a questionnaire, and at a result.
- `--help` shows usage; an unknown argument exits 2. Redirected output contains no ANSI escapes.

For a reproducible common-path smoke, pipe seven `1` lines followed by `quit` to `repolicense --plain`: one chooses the questionnaire from the start menu, then six reach MIT. Expect `License: MIT` and exit 0. Also select Check compatibility from the start menu and submit a canonical SPDX list, ensuring buffered input survives the mode transition. `--compat` / `-c` must bypass the launcher. Do not use old yes/no scripts: menus are multi-choice.

## Gum terminal smoke

Install Gum separately and run the real CLI in a terminal with `TERM` not `dumb` (Gum 2.0.2 has been exercised). Verify the colored header, rounded question and result panels, highlighted cursor, arrow-key/Enter selection, and complete MIT path. Exercise Software → Ownership → Back → Restart: the visible screen must contain only the current question. Exercise Font → ownership → new font → reject: the visible screen must show the OFL-mismatch advisory, not a previous question. Check a narrow terminal with `COLUMNS` set and the longest result. Esc/Ctrl-C cancels without a recommendation inferred from cancellation. Gum renders the menus; the parent replaces views without counting Gum frame lines.

Run `--compat` at 80×24, select MIT plus Apache-2.0, and submit. The compact overview must show selected IDs, common-target outcome, ordinary/conditional counts, and all three actions without scrolling. View targets and conditions must open a scrollable full assessment; `q` returns to the overview. Check another combination explicitly reopens selection; Quit exits. Also check GPL-2.0-only + Apache-2.0 (no supported target) and MIT + OFL-1.1 (conditional-only), without implying blanket relicensing. Tab toggles and advances in the picker; Ctrl-C cancels. Gum version 2 exits 1 for both Esc and some runtime errors, so retain diagnostics and never infer a negative answer.

Repeat with Gum absent from `PATH` and with `--plain` even while Gum is present: numbered questionnaire prompts must replace the terminal viewport on forward, Back, and Restart transitions. Only the current question should remain visible, including when long text wraps. Redirected streams and `TERM=dumb` must instead retain plain transcripts without controls. The missing-Gum compatibility fallback accepts canonical SPDX lists or numbered options on its first picker; subsequent inputs use canonical lists.

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

Ensure `$HOME/.local/bin` is on `PATH` or that your configured shell alias resolves to the current build. CI compiles and runs tests on Linux, macOS, and Windows. Native terminal behavior still needs the real Gum/plain smoke checks above; cross-compilation alone does not prove it.
