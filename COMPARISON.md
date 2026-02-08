# Comparison: Web vs CLI

## Overview

This CLI tool (`repolicense-cli`) is a command-line implementation of the web-based [repolicense](https://github.com/lucasfth/repolicense) tool.

## Features Comparison

| Feature | Web Version | CLI Version |
|---------|-------------|-------------|
| Decision Tree Navigation | ✅ Yes/No buttons | ✅ Text input (yes/no) |
| Back Navigation | ✅ Back button | ✅ `back` command |
| Reset | ✅ Reset button | ✅ `reset` command |
| License Information | ✅ Fetches from GitHub API | ✅ Provides API links |
| Session Persistence | ✅ SessionStorage | ❌ Not needed (CLI session) |
| Elaboration Display | ✅ Collapsible details | ✅ Always shown |
| Mermaid Diagram Export | ✅ Copy to clipboard | ❌ Not implemented |
| Download Tree | ✅ JSON download | ❌ Not implemented |
| Visual Design | ✅ Modern UI with Shoelace | ✅ Clean text output |
| License Compatibility Checker | ❌ Not implemented | ✅ New feature for checking compatible licenses when forking/combining projects |
| Platform | 🌐 Browser-based | 💻 Native CLI |

## Architecture Differences

### Web Version
- **Language**: JavaScript
- **UI Framework**: HTML/CSS with Shoelace components
- **Storage**: Browser SessionStorage
- **API Calls**: Direct fetch to GitHub API
- **Tree Structure**: JavaScript object literals

### CLI Version
- **Language**: Zig
- **UI**: Terminal text interface
- **Storage**: In-memory (per session)
- **API Calls**: Provides links (no direct calls)
- **Tree Structure**: Zig const structs with compile-time guarantees

## Decision Tree Logic

Both versions implement the **exact same decision tree logic**:
- Same questions
- Same elaborations
- Same license recommendations
- Same paths to each license

The core decision-making algorithm has been faithfully ported from JavaScript to Zig.

## Advantages of Each Version

### Web Version Advantages
- No installation required
- Visual, clickable interface
- Works on any device with a browser
- Export features (Mermaid, JSON)
- Visual feedback and animations

### CLI Version Advantages
- Works offline (no internet required)
- Fast and lightweight
- No browser overhead
- Can be scripted/automated
- Native performance
- Privacy (no web analytics)
- Integrates with terminal workflows

## Use Cases

### Use Web Version When:
- You prefer visual interfaces
- You want to export diagrams
- You're on a device without Zig
- You want to share results easily

### Use CLI Version When:
- You prefer terminal interfaces
- You're working in a remote/SSH session
- You want offline access
- You need a lightweight tool
- You're building scripts around license selection

## Implementation Notes

The CLI version was designed to be:
1. **Faithful**: Same decision tree and logic
2. **Standalone**: No external dependencies beyond Zig stdlib
3. **Simple**: Easy to build and use
4. **Maintainable**: Clean, readable Zig code
5. **Portable**: Works on Linux, macOS, and Windows

## Future Enhancements

Potential additions to CLI version:
- [ ] Fetch and display full license text from GitHub API
- [ ] Save/load session state to file
- [ ] Export decision path
- [ ] Color output support
- [ ] Batch mode for scripting
- [ ] Configuration file support
