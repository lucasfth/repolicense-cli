# Test Plan for repolicense-cli

## Manual Testing Checklist

### Basic Navigation
- [ ] Start the program and see welcome message
- [ ] Answer "yes" to first question
- [ ] Answer "no" to first question
- [ ] Use back command to go to previous question
- [ ] Use reset command to return to start
- [ ] Use quit command to exit

### License Paths Testing

#### Permissive Licenses
- [ ] Navigate to MIT license (yes > yes > yes > yes)
- [ ] Navigate to BSD-2-Clause (yes > yes > yes > no)
- [ ] Navigate to Apache-2.0 (yes > yes > no > yes)
- [ ] Navigate to BSD-3-Clause (yes > yes > no > no > yes)
- [ ] Navigate to 0BSD (yes > yes > no > no > no > yes)
- [ ] Navigate to ISC (yes > yes > no > no > no > no)

#### Copyleft Licenses
- [ ] Navigate to AGPL-3.0 (yes > no > yes > yes > yes)
- [ ] Navigate to GPL-3.0 (yes > no > yes > yes > no > yes)
- [ ] Navigate to GPL-2.0 (yes > no > yes > yes > no > no)
- [ ] Navigate to LGPL-3.0 (yes > no > yes > no > yes)
- [ ] Navigate to MPL-2.0 (yes > no > yes > no > no > yes)
- [ ] Navigate to EPL-2.0 (yes > no > yes > no > no > no > yes)
- [ ] Navigate to EPL-1.0 (yes > no > yes > no > no > no > no)

#### Other Licenses
- [ ] Navigate to Unlicense (yes > no > no > yes)
- [ ] Navigate to OFL-1.1 (yes > no > no > no > yes)
- [ ] Navigate to proprietary advice (yes > no > no > no > no)
- [ ] Navigate to closed-source advice (no)

### Input Validation
- [ ] Test with uppercase input (YES, NO)
- [ ] Test with mixed case input (Yes, No)
- [ ] Test with short forms (y, n, b, r, q)
- [ ] Test with invalid input (gibberish)
- [ ] Test with empty input

### Edge Cases
- [ ] Use back at the start (should show message)
- [ ] Use reset at the start (should work)
- [ ] Use back and reset multiple times
- [ ] Navigate to end, then back through entire tree
- [ ] Try commands at answer nodes

### Output Verification
- [ ] Questions display correctly with elaboration
- [ ] Answers display with license name
- [ ] GitHub API links show for official licenses
- [ ] No GitHub links for advisory answers
- [ ] All formatting is readable

## Automated Testing

To add automated tests, create `src/main_test.zig`:

```zig
const std = @import("std");
const testing = std.testing;

test "decision tree root exists" {
    const decision_tree = @import("main.zig").decision_tree;
    try testing.expect(decision_tree.node_type == .Question);
}

test "all leaf nodes are answers" {
    // Add tests to verify tree structure
}
```

Run with: `zig build test`

## Performance Testing
- [ ] Test with rapid input
- [ ] Test memory usage with long sessions
- [ ] Verify no memory leaks

## Cross-Platform Testing
- [ ] Test on Linux
- [ ] Test on macOS
- [ ] Test on Windows
- [ ] Test on different terminal emulators
