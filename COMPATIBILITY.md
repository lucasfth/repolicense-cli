# License Compatibility Guide

## Overview

The license compatibility checker helps you determine which licenses you can use when forking or combining projects with existing licenses. This is particularly useful when:

- Forking a repository and planning to make significant changes
- Combining code from multiple open-source projects
- Adding dependencies with different licenses to your project
- Understanding license requirements for derivative works

## How to Use

Run the compatibility checker:

```bash
./zig-out/bin/repolicense compat
```

Enter a comma-separated list of licenses:

```
Enter licenses: MIT, Apache-2.0
```

The tool will show you:
1. All licenses compatible with your combination
2. Pairwise compatibility details
3. Explanations for why licenses are compatible or not

## Compatibility Rules

### Permissive Licenses

**MIT, BSD-2-Clause, BSD-3-Clause, ISC, 0BSD**
- ✅ Can be combined with most other licenses
- ✅ Allow relicensing under copyleft licenses
- ✅ Very flexible and business-friendly
- ❌ Cannot be combined with specialized licenses (like OFL-1.1)

**Apache-2.0**
- ✅ Similar to other permissive licenses
- ✅ Includes explicit patent grants
- ✅ Compatible with GPL-3.0 and AGPL-3.0
- ❌ **Incompatible with GPL-2.0** due to patent clause differences

### Strong Copyleft Licenses

**GPL-3.0**
- ✅ Compatible with GPL-3.0 and AGPL-3.0
- ❌ Requires derivative works to use GPL-3.0 or compatible
- ❌ Not compatible with most other licenses

**GPL-2.0**
- ✅ Compatible with GPL-2.0 and GPL-3.0
- ❌ Incompatible with Apache-2.0
- ❌ Very restrictive on derivative works

**AGPL-3.0**
- ✅ Only compatible with itself
- ❌ Most restrictive copyleft license
- ❌ Requires source distribution even for network services

### Weak Copyleft Licenses

**LGPL-3.0**
- ✅ Allows linking with proprietary software
- ✅ Compatible with most permissive licenses
- ✅ Can be used with GPL-3.0
- 📝 File-level copyleft (modifications stay open, but can link with closed)

**MPL-2.0**
- ✅ File-level copyleft
- ✅ Compatible with GPL-3.0
- ✅ More business-friendly than GPL

**EPL-2.0, EPL-1.0**
- ✅ Business-friendly weak copyleft
- ❌ Not compatible with strong copyleft licenses

### Special Cases

**Unlicense**
- ✅ Public domain dedication
- ✅ Compatible with everything
- ✅ Most permissive possible

**OFL-1.1 (Open Font License)**
- ✅ Only compatible with itself
- ❌ Specialized for fonts
- ❌ Cannot be combined with other license types

## Common Scenarios

### Scenario 1: Forking a Permissive Project

If you fork a project under MIT or Apache-2.0:
- ✅ You can keep the same license
- ✅ You can upgrade to a copyleft license (GPL, AGPL)
- ✅ You can choose another permissive license
- 📝 You must preserve copyright notices

### Scenario 2: Combining Multiple Permissive Projects

Combining MIT + BSD-3-Clause + Apache-2.0:
- ✅ Very flexible
- ✅ Can use any of the original licenses
- ✅ Can upgrade to GPL-3.0 or AGPL-3.0
- ❌ Cannot use GPL-2.0 (due to Apache-2.0)

### Scenario 3: Working with GPL Code

If any project uses GPL-3.0:
- ❌ Your derivative must be GPL-3.0 or AGPL-3.0
- ❌ Cannot combine with proprietary code
- ❌ Very limited options

### Scenario 4: Library Linking

If you're using libraries:
- LGPL-3.0: ✅ Can link with your proprietary code
- MPL-2.0: ✅ File-level, modifications stay open
- GPL: ❌ Makes your entire project GPL

## Best Practices

1. **Check licenses early**: Review licenses before investing time
2. **Document dependencies**: Keep track of all dependency licenses
3. **Be conservative**: When in doubt, consult with legal counsel
4. **Consider patents**: Apache-2.0 provides patent protection
5. **Think about users**: Choose licenses that work for your user base

## Examples

### Example 1: Web Application

```
Projects: React (MIT), Express (MIT), some-library (Apache-2.0)
Compatible licenses: MIT, BSD-*, Apache-2.0, GPL-3.0, LGPL-3.0, MPL-2.0
Recommendation: Keep MIT for maximum flexibility
```

### Example 2: Fork with Additional Code

```
Original: some-tool (GPL-3.0)
Adding: utility-lib (MIT)
Compatible licenses: GPL-3.0, AGPL-3.0 only
Reason: GPL-3.0 is strong copyleft, must use compatible license
```

### Example 3: Multiple Dependencies

```
Projects: lib-a (MIT), lib-b (Apache-2.0), lib-c (GPL-2.0)
Compatible licenses: None
Issue: Apache-2.0 and GPL-2.0 are incompatible
Solution: Replace lib-c or lib-b with compatible alternatives
```

## Limitations

This tool provides guidance based on common license compatibility rules, but:

- 🔸 License compatibility can be complex
- 🔸 Some situations require legal interpretation
- 🔸 Different jurisdictions may have different rules
- 🔸 Always consult with a lawyer for commercial projects

## Further Reading

- [Choose a License](https://choosealicense.com/)
- [GNU License Compatibility](https://www.gnu.org/licenses/license-compatibility.html)
- [OSI Approved Licenses](https://opensource.org/licenses)
- [GitHub Licensing Guide](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
