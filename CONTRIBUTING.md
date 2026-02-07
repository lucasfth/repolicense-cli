# Contributing to repolicense-cli

Thank you for your interest in contributing to repolicense-cli!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/repolicense-cli.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`

## Prerequisites

- Zig 0.13.0 or later: [Download Zig](https://ziglang.org/download/)

## Building

```bash
zig build
```

## Running Tests

```bash
zig build test
```

## Code Style

- Follow Zig standard library conventions
- Use 4 spaces for indentation
- Keep functions focused and concise
- Add comments for complex logic

## Adding New Licenses

To add a new license to the decision tree:

1. Open `src/main.zig`
2. Add a new `Node` constant in the `buildDecisionTree()` function
3. Update the tree structure to include your new license
4. Update the README with the new license information

## Submitting Changes

1. Commit your changes: `git commit -m "Description of changes"`
2. Push to your fork: `git push origin feature/your-feature-name`
3. Open a Pull Request

## Questions?

Feel free to open an issue for any questions or concerns.
