# Installation Guide

This guide helps you set up the markdown-cv repo on your system.

## Quick Start (Linux/macOS)

### 1. Install Prerequisites

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install -y pandoc texlive texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra
```

(`texlive-fonts-extra` provides the `fontawesome5` icon package.)

#### Fedora/RHEL:
```bash
sudo dnf install -y pandoc texlive texlive-latex texlive-fonts-extra
```

#### Arch Linux:
```bash
sudo pacman -S --needed pandoc texlive-core texlive-latexextra texlive-fontsextra
```

#### macOS (Homebrew):
```bash
brew install pandoc mactex
# Add TeX Live to PATH
echo 'export PATH="/usr/local/texlive/2024/bin/x86_64-darwin:$PATH"' >> ~/.zshrc
echo 'export PATH="/usr/local/texlive/2024/bin/x86_64-darwin:$PATH"' >> ~/.bashrc
source ~/.zshrc  # or ~/.bashrc
```

### 2. Clone and Build

```bash
git clone <your-repo-url> markdown-cv
cd markdown-cv

# Build the CV
pandoc example-cv.md --defaults=pdf.yaml -o example-cv.pdf

# Or use the build script
chmod +x build.sh
./build.sh
```

## Quick Start (Windows)

### 1. Install Prerequisites

#### Option A: MiKTeX (Recommended)
1. Download MiKTeX from: https://miktex.org/download
2. Run the installer (basic or complete)
3. Ensure MiKTeX binaries are in your PATH

#### Option B: TeX Live
1. Download TeX Live from: https://tug.org/texlive/
2. Run the installer
3. Add TeX Live to your PATH

#### Option C: Portable Solutions
- **wkhtmltopdf**: Download from https://wkhtmltopdf.org/
- **weasyprint**: `pip install weasyprint`

### 2. Clone and Build

```powershell
git clone <your-repo-url> markdown-cv
cd markdown-cv

# Build the CV
pandoc example-cv.md --defaults=pdf.yaml -o example-cv.pdf

# Or use the build script
./build.ps1
```

## Alternative: Docker

If you don't want to install TeX on your system, use Docker:

```bash
# Build using a Docker container with TeX Live
docker run --rm -v $(pwd):/work -w /work texlive/texlive:latest \
  pandoc example-cv.md --defaults=pdf.yaml -o example-cv.pdf
```

Or create a docker-compose.yml:

```yaml
version: '3'
services:
  cv-builder:
    image: texlive/texlive:latest
    volumes:
      - .:/work
    working_dir: /work
    command: pandoc example-cv.md --defaults=pdf.yaml -o example-cv.pdf
```

Then run:
```bash
docker-compose up
```

## Troubleshooting

### "pdflatex not found" Error

This means TeX is not installed or not in your PATH.

**Linux/macOS:**
```bash
# Check if installed
which pdflatex

# If not, install it (see above)
```

**Windows:**
```powershell
# Check if installed
Get-Command pdflatex

# If not, install MiKTeX or TeX Live (see above)
```

### FontAwesome Icons Not Showing

The build uses the `fontawesome5` LaTeX package:

**Linux (TeX Live):**
```bash
sudo apt install texlive-fonts-extra
```

**Windows (MiKTeX):**
- Open MiKTeX Console
- Go to "Packages"
- Search for "fontawesome5" and install it
- Or enable automatic on-the-fly installation (recommended, stops the
  one-package-at-a-time confirm dialogs):

```powershell
initexmf --set-config-value=[MPM]AutoInstall=1
```

The other packages the preamble needs (`multicol`, `fancyhdr`,
`titlesec`, `enumitem`, `booktabs`, ...) ship with the standard
distributions or are fetched automatically the same way.

### Table Wrapping Issues

The `table-widths.lua` filter should handle this automatically. If tables still overflow:
- Check that the filter is referenced in `pdf.yaml`
- Ensure the filter path is correct

## Verification

To verify everything is working:

```bash
# Check pandoc version
pandoc --version

# Check TeX engine
pdflatex --version

# Test build
pandoc example-cv.md --defaults=pdf.yaml -o test.pdf
```

If all commands succeed, your setup is complete!
