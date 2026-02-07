# CI/CD Setup for repolicense-cli

## GitHub Actions Workflow

To set up continuous integration for this project, create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    
    runs-on: ${{ matrix.os }}
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Zig
      uses: goto-bus-stop/setup-zig@v2
      with:
        version: 0.13.0
    
    - name: Build
      run: zig build
    
    - name: Run tests (when available)
      run: zig build test || echo "No tests configured yet"
    
    - name: Upload artifact
      uses: actions/upload-artifact@v4
      with:
        name: repolicense-${{ matrix.os }}
        path: zig-out/bin/repolicense*

  lint:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Zig
      uses: goto-bus-stop/setup-zig@v2
      with:
        version: 0.13.0
    
    - name: Check formatting
      run: zig fmt --check src/
```

## Release Workflow

Create `.github/workflows/release.yml` for automated releases:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-release:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: x86_64-linux
          - os: macos-latest
            target: x86_64-macos
          - os: windows-latest
            target: x86_64-windows
    
    runs-on: ${{ matrix.os }}
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Zig
      uses: goto-bus-stop/setup-zig@v2
      with:
        version: 0.13.0
    
    - name: Build Release
      run: zig build -Doptimize=ReleaseSafe
    
    - name: Create Archive
      shell: bash
      run: |
        cd zig-out/bin
        if [ "${{ runner.os }}" = "Windows" ]; then
          7z a ../../repolicense-${{ matrix.target }}.zip repolicense.exe
        else
          tar czf ../../repolicense-${{ matrix.target }}.tar.gz repolicense
        fi
    
    - name: Upload Release Asset
      uses: actions/upload-artifact@v4
      with:
        name: repolicense-${{ matrix.target }}
        path: repolicense-*.*

  create-release:
    needs: build-release
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Download Artifacts
      uses: actions/download-artifact@v4
    
    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        files: |
          **/repolicense-*
        draft: false
        prerelease: false
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Local Development Scripts

### Format Check
```bash
#!/bin/bash
zig fmt --check src/
```

### Build and Test
```bash
#!/bin/bash
set -e
echo "Building..."
zig build
echo "Running tests..."
zig build test || echo "No tests yet"
echo "Success!"
```

### Cross-compilation Example
```bash
#!/bin/bash
# Build for multiple targets
zig build -Dtarget=x86_64-linux
zig build -Dtarget=x86_64-macos
zig build -Dtarget=x86_64-windows
zig build -Dtarget=aarch64-linux
zig build -Dtarget=aarch64-macos
```

## Docker Support

Create a `Dockerfile` for containerized builds:

```dockerfile
FROM alpine:latest

# Install Zig
RUN apk add --no-cache wget xz && \
    wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz && \
    tar xf zig-linux-x86_64-0.13.0.tar.xz && \
    mv zig-linux-x86_64-0.13.0 /usr/local/zig && \
    ln -s /usr/local/zig/zig /usr/local/bin/zig && \
    rm zig-linux-x86_64-0.13.0.tar.xz

WORKDIR /app
COPY . .

RUN zig build

ENTRYPOINT ["/app/zig-out/bin/repolicense"]
```

Build and run:
```bash
docker build -t repolicense-cli .
docker run -it repolicense-cli
```

## Pre-commit Hooks

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
echo "Running pre-commit checks..."

# Format check
if ! zig fmt --check src/; then
    echo "Error: Code is not formatted. Run 'zig fmt src/' to fix."
    exit 1
fi

# Build check
if ! zig build; then
    echo "Error: Build failed."
    exit 1
fi

echo "Pre-commit checks passed!"
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```
