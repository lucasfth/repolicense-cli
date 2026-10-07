# Decision tree

The CLI's tree is obligation-driven rather than a ranking of licenses from “simple” to “strong.” Its recommendations and `--compat` share the canonical SPDX catalog in `src/licenses.zig`. All 23 licenses and four advisory outcomes have explicit preference-path coverage in `src/tree_test.zig`.

## Entry and scope

```mermaid
flowchart TD
    Font{Licensing a font?}
    Font -->|Yes| FontRights{Allow use, embedding, modification, and redistribution?}
    FontRights -->|Yes| OFL[OFL-1.1]
    FontRights -->|No| FontAdvice[No matching font recommendation]
    Font -->|No| Ownership{Software you have the right to license?}
    Ownership -->|No| OwnershipAdvice[Resolve ownership and existing obligations]
    Ownership -->|Yes| Rights{Allow use, modification, redistribution, and commercial use?}
    Rights -->|No| RightsAdvice[Open-source terms do not fit reserved rights]
    Rights -->|Yes| Sharing{Source-sharing for distribution or modified network services?}
    Sharing -->|No| Permissive[Permissive path]
    Sharing -->|Yes| Copyleft[Copyleft path]
```

OFL fonts keep their own terms, including Reserved Font Names and the restriction on selling fonts by themselves. Documents made with those fonts do not inherit OFL. The software path assumes you have licensing rights; existing component licenses cannot be replaced just by choosing a new project license. Documentation and other non-font assets are outside this tree.

## Permissive path

```mermaid
flowchart TD
    Patents{Express contributor patent license?}
    Patents -->|Yes| Apache[Apache-2.0]
    Patents -->|No| Dedication{Public-domain dedication?}
    Dedication -->|Yes| Unlicense[Unlicense]
    Dedication -->|No| Notices{Waive notice-copy requirements?}
    Notices -->|Yes| Zero[0BSD]
    Notices -->|No| Binary{Source notices enough; no binary notice-copy requirement?}
    Binary -->|Yes| Marking{Require origin integrity and marked altered source?}
    Marking -->|Yes| Zlib[Zlib]
    Marking -->|No| Boost[BSL-1.0]
    Binary -->|No| Endorsement{Explicit no-endorsement clause?}
    Endorsement -->|Yes| BSD3[BSD-3-Clause]
    Endorsement -->|No| BSDPreference{BSD-2-Clause ecosystem preference?}
    BSDPreference -->|Yes| BSD2[BSD-2-Clause]
    BSDPreference -->|No| ISCPreference{ISC ecosystem preference?}
    ISCPreference -->|Yes| ISC[ISC]
    ISCPreference -->|No| MIT[MIT]
```

The patent question precedes all permissive recommendations. Apache adds express patent grants, change notices, and applicable NOTICE attributions. MIT, BSD, and ISC preserve notices rather than eliminating conditions. `0BSD` retains copyright without a notice-copy requirement; `Unlicense` attempts a public-domain dedication. Boost's binary exemption differs from Zlib's altered-source/origin rules. `BSL-1.0` means **Boost**, not the Business Source License.

## Copyleft path

```mermaid
flowchart TD
    Network{Source offer to remote users of modified network versions?}
    Network -->|Yes| AGPLLater{Permit later AGPL versions?}
    AGPLLater -->|Yes| AGPLLaterLeaf[AGPL-3.0-or-later]
    AGPLLater -->|No| AGPLOnly[AGPL-3.0-only]
    Network -->|No| Program{Copyleft covers combined program?}
    Program -->|Yes| GPLLegacy{Existing project requires GPL version 2?}
    GPLLegacy -->|Yes| GPL2Later{Permit later GPL versions?}
    GPL2Later -->|Yes| GPL2LaterLeaf[GPL-2.0-or-later]
    GPL2Later -->|No| GPL2Only[GPL-2.0-only]
    GPLLegacy -->|No| GPL3Later{Permit later GPL versions?}
    GPL3Later -->|Yes| GPL3LaterLeaf[GPL-3.0-or-later]
    GPL3Later -->|No| GPL3Only[GPL-3.0-only]
    Program -->|No| Library{Library boundary with relinking rights?}
    Library -->|Yes| LGPLLegacy{Existing library requires LGPL version 2.1?}
    LGPLLegacy -->|Yes| LGPL21Later{Permit later LGPL versions?}
    LGPL21Later -->|Yes| LGPL21LaterLeaf[LGPL-2.1-or-later]
    LGPL21Later -->|No| LGPL21Only[LGPL-2.1-only]
    LGPLLegacy -->|No| LGPL3Later{Permit later LGPL versions?}
    LGPL3Later -->|Yes| LGPL3LaterLeaf[LGPL-3.0-or-later]
    LGPL3Later -->|No| LGPL3Only[LGPL-3.0-only]
    Library -->|No| Files{File-level copyleft?}
    Files -->|Yes| MPL[MPL-2.0]
    Files -->|No| Eclipse{Eclipse ecosystem requirement?}
    Eclipse -->|Yes| EPLLegacy{Existing project requires EPL version 1.0?}
    EPLLegacy -->|Yes| EPL1[EPL-1.0]
    EPLLegacy -->|No| EPL2[EPL-2.0]
    Eclipse -->|No| Advice[No matching copyleft recommendation]
```

GPL covers covered combined programs, LGPL provides library-level permissions with source/relinking conditions, and MPL keeps covered files under its terms while separate files may differ. EPL is selected for an explicit ecosystem requirement, not vague “business-friendly” preferences.

Ordinary copyleft distribution obligations do not require publishing every private modification. AGPL adds a source offer to remote users of a modified network version. Existing projects must already grant any selected later-version permission, or you must own the rights to grant it. LGPL-2.1's GPL conversion option is not permission to upgrade an LGPL-2.1-only library to LGPL-3.0.

## Compatibility is a separate assessment

A recommendation describes suitable terms for work you can license. `--compat` instead considers **all existing licenses** and distinguishes ordinary compliance from conditions requiring separate libraries/files, font bundling, GNU module combinations, or secondary-license grants. Pairwise checks search for a common target; they are not symmetric relicensing permissions.

In particular, GPL-2.0-only and GPL-3.0 cannot be freely combined, while GPL-2.0-or-later permits selecting version 3. GPL/AGPL version-3 combinations retain separate module licenses under section 13. MPL secondary licensing depends on eligibility and an actual larger work with secondary-licensed material. EPL secondary licensing needs the initial contributor's specific Exhibit A notice; including the template license text does not supply that grant.

## Authoritative references

- [GNU license compatibility list](https://www.gnu.org/licenses/license-list.html) and [GNU compatibility matrix](https://www.gnu.org/licenses/gpl-faq.html#AllCompatibility).
- [LGPL-2.1 section 3: GPL conversion](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html) and [GPL-3.0 section 13: AGPL combinations](https://spdx.org/licenses/GPL-3.0-only.html).
- [MPL-2.0 section 3.3](https://spdx.org/licenses/MPL-2.0.html) and [Mozilla's MPL FAQ](https://www.mozilla.org/en-US/MPL/2.0/FAQ/).
- [EPL-2.0 section 3.2 and Exhibit A](https://spdx.org/licenses/EPL-2.0.html).
- [Boost Software License](https://www.boost.org/LICENSE_1_0.txt), [Zlib](https://spdx.org/licenses/Zlib.html), and [official OFL text](https://openfontlicense.org/open-font-license-official-text/).

This is general guidance, not legal advice. Review the applicable license texts, notices, and how your code is combined.
