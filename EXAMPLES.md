# Usage Examples

## Example 1: Choosing the MIT License

```
=== Repolicense CLI ===
Welcome to Repolicense! This tool helps you choose the right open-source license.
Answer the questions with 'yes', 'no', 'back', 'reset', or 'quit'.

--- Question ---
Do you want to open-source your project?

Elaboration: Do you want to make your source code publicly available and allow others to use, modify, and distribute it.

Your answer (yes/no/back/reset/quit): yes

--- Question ---
Do you want a permissive license?

Elaboration: Do you want a more lenient license and allow others to use, modify, and distribute your code with minimal restrictions. These licenses are generally business-friendly and encourage wider use.

Your answer (yes/no/back/reset/quit): yes

--- Question ---
Do you require minimal conditions?

Elaboration: Do you want minimal conditions meaning that there are very few requirements placed on the use of your code. This typically includes providing attribution to the original authors.

Your answer (yes/no/back/reset/quit): yes

--- Question ---
Do you want the simplest and most permissive license possible?

Elaboration: Do you want a license that is very permissive and has minimal requirements, making it as simple as possible for others to use your code.

Your answer (yes/no/back/reset/quit): yes

=== RESULT ===
License: MIT

For more information, visit:
https://api.github.com/licenses/MIT
https://docs.github.com/en/rest/licenses/licenses

Options: back/reset/quit: quit

Thank you for using Repolicense!
```

## Example 2: Exploring with Back and Reset

```
--- Question ---
Do you want to open-source your project?

Your answer (yes/no/back/reset/quit): yes

--- Question ---
Do you want a permissive license?

Your answer (yes/no/back/reset/quit): no

--- Question ---
Do you want a copyleft license?

Your answer (yes/no/back/reset/quit): back

[Moved back]

--- Question ---
Do you want a permissive license?

Your answer (yes/no/back/reset/quit): reset

[Reset to beginning]

--- Question ---
Do you want to open-source your project?

Your answer (yes/no/back/reset/quit): quit

Thank you for using Repolicense!
```

## Example 3: Choosing GPL-3.0

```
--- Question ---
Do you want to open-source your project?
Your answer: yes

--- Question ---
Do you want a permissive license?
Your answer: no

--- Question ---
Do you want a copyleft license?
Your answer: yes

--- Question ---
Do you want strong copyleft?
Your answer: yes

--- Question ---
Do you want network server protection?
Your answer: no

--- Question ---
Do you want to use the latest version of the GPL license?
Your answer: yes

=== RESULT ===
License: GPL-3.0

For more information, visit:
https://api.github.com/licenses/GPL-3.0
https://docs.github.com/en/rest/licenses/licenses
```

## Example 4: Deciding Not to Open Source

```
--- Question ---
Do you want to open-source your project?

Elaboration: Do you want to make your source code publicly available and allow others to use, modify, and distribute it.

Your answer (yes/no/back/reset/quit): no

=== RESULT ===
License: You should consider keeping your project closed-source.

You should consider keeping your project closed-source to protect your intellectual property by not sharing the source code.

Options: back/reset/quit: quit

Thank you for using Repolicense!
```

## Quick Reference: License Decision Paths

### Permissive Licenses
- **MIT**: yes → yes → yes → yes
- **BSD-2-Clause**: yes → yes → yes → no
- **Apache-2.0**: yes → yes → no → yes
- **BSD-3-Clause**: yes → yes → no → no → yes
- **0BSD**: yes → yes → no → no → no → yes
- **ISC**: yes → yes → no → no → no → no

### Copyleft Licenses
- **AGPL-3.0**: yes → no → yes → yes → yes
- **GPL-3.0**: yes → no → yes → yes → no → yes
- **GPL-2.0**: yes → no → yes → yes → no → no
- **LGPL-3.0**: yes → no → yes → no → yes
- **MPL-2.0**: yes → no → yes → no → no → yes
- **EPL-2.0**: yes → no → yes → no → no → no → yes
- **EPL-1.0**: yes → no → yes → no → no → no → no

### Other
- **Unlicense**: yes → no → no → yes
- **OFL-1.1**: yes → no → no → no → yes
- **Closed Source**: no
