# repolicense-cli

A command-line tool to help you choose the right open-source license for your project, implemented in Zig.

This is a CLI version of [repolicense](https://github.com/lucasfth/repolicense), which guides you through a series of questions to determine the most suitable license for your needs.

## Features

- Interactive question-and-answer interface
- Navigate forward and backward through the decision tree
- Reset at any time to start over
- Get detailed information about each license
- Links to GitHub API for license details
- **NEW**: License compatibility checker for forking projects

## Prerequisites

- [Zig](https://ziglang.org/download/) version 0.13.0 or later

## Building

```bash
zig build
```

## Running

After building, run the executable:

```bash
./zig-out/bin/repolicense
```

Or build and run in one command:

```bash
zig build run
```

### License Compatibility Mode

To check which licenses you can use when forking or combining projects:

```bash
./zig-out/bin/repolicense compat
```

This mode helps you determine compatible licenses when you want to combine code from multiple projects with different licenses.

## Usage

### License Selection Mode (Default)

The tool will ask you a series of yes/no questions about your project requirements. Based on your answers, it will recommend an appropriate open-source license.

Available commands:
- `yes` or `y` - Answer yes to the current question
- `no` or `n` - Answer no to the current question
- `back` or `b` - Go back to the previous question
- `reset` or `r` - Start over from the beginning
- `quit` or `q` - Exit the program

### License Compatibility Mode

Run with `compat` argument to check license compatibility:

```bash
./zig-out/bin/repolicense compat
```

This mode allows you to:
- Enter a comma-separated list of licenses from projects you want to combine
- See which licenses are compatible with all of them
- Understand why certain combinations are compatible or not

Example:
```
Enter licenses: MIT, Apache-2.0
✅ You can use any of these licenses for your combined work:
  • MIT
  • BSD-2-Clause
  • Apache-2.0
  • GPL-3.0
  ...
```

## Example

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
...
```

## Supported Licenses

The tool helps you choose from the following licenses:

- **Permissive**: MIT, BSD-2-Clause, BSD-3-Clause, Apache-2.0, 0BSD, ISC
- **Copyleft**: GPL-2.0, GPL-3.0, AGPL-3.0, LGPL-3.0, MPL-2.0, EPL-1.0, EPL-2.0
- **Public Domain**: Unlicense
- **Specialized**: OFL-1.1 (for fonts)

## Testing

Run the test suite:

```bash
zig build test
```

The test suite includes:
- Decision tree structure validation
- License compatibility logic tests
- Navigation and path verification

## License

This project is licensed under the GNU General Public License Version 3.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

Based on the original [repolicense](https://github.com/lucasfth/repolicense) web application.