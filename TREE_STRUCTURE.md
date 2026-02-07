# Decision Tree Structure

## Complete Tree Visualization

```
Do you want to open-source your project?
├─ Yes → Do you want a permissive license?
│  ├─ Yes → Do you require minimal conditions?
│  │  ├─ Yes → Do you want the simplest and most permissive license possible?
│  │  │  ├─ Yes → MIT
│  │  │  └─ No → BSD-2-Clause
│  │  └─ No → Do you want explicit patent grants?
│  │     ├─ Yes → Apache-2.0
│  │     └─ No → Do you want a permissive license with some conditions?
│  │        ├─ Yes → BSD-3-Clause
│  │        └─ No → Do you want the simplest permissive license with no conditions?
│  │           ├─ Yes → 0BSD
│  │           └─ No → ISC
│  └─ No → Do you want a copyleft license?
│     ├─ Yes → Do you want strong copyleft?
│     │  ├─ Yes → Do you want network server protection?
│     │  │  ├─ Yes → AGPL-3.0
│     │  │  └─ No → Do you want to use the latest version of the GPL license?
│     │  │     ├─ Yes → GPL-3.0
│     │  │     └─ No → GPL-2.0
│     │  └─ No → Do you want to allow linking with non-(L)GPL software?
│     │     ├─ Yes → LGPL-3.0
│     │     └─ No → Do you want a copyleft license with weaker requirements?
│     │        ├─ Yes → MPL-2.0
│     │        └─ No → Do you prefer a copyleft license with a focus on business-friendly terms?
│     │           ├─ Yes → EPL-2.0
│     │           └─ No → EPL-1.0
│     └─ No → Do you want to dedicate your work to the public domain?
│        ├─ Yes → Unlicense
│        └─ No → Do you want a license for fonts?
│           ├─ Yes → OFL-1.1
│           └─ No → Consider using a proprietary license
└─ No → You should consider keeping your project closed-source

```

## License Categories

### Permissive Licenses (6)
1. **MIT** - Simplest and most permissive
2. **BSD-2-Clause** - Simple permissive, not quite as minimal as MIT
3. **Apache-2.0** - Permissive with explicit patent grants
4. **BSD-3-Clause** - Permissive with additional conditions
5. **0BSD** - Simplest with no conditions
6. **ISC** - Alternative simple permissive

### Strong Copyleft Licenses (3)
7. **AGPL-3.0** - Strongest copyleft with network server protection
8. **GPL-3.0** - Strong copyleft, latest version
9. **GPL-2.0** - Strong copyleft, older version

### Weak Copyleft Licenses (4)
10. **LGPL-3.0** - Allows linking with non-(L)GPL software
11. **MPL-2.0** - Weaker copyleft requirements
12. **EPL-2.0** - Business-friendly copyleft (newer)
13. **EPL-1.0** - Business-friendly copyleft (older)

### Public Domain (1)
14. **Unlicense** - Dedicates work to public domain

### Specialized (1)
15. **OFL-1.1** - Font license

### Advisory Results (2)
16. **Proprietary** - Use proprietary or specialized license
17. **Closed-Source** - Keep project closed-source

## Decision Tree Depth

- Maximum depth: 7 questions
- Minimum depth: 1 question
- Average depth: ~4 questions

## Question Flow Paths

Total unique paths to licenses: 17
- 6 paths to permissive licenses (depth 4-6)
- 7 paths to copyleft licenses (depth 5-7)
- 1 path to public domain (depth 4)
- 1 path to font license (depth 5)
- 2 paths to advisories (depth 1-5)
