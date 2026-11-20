#!/bin/bash
# Build script for Unix-like systems (Linux, macOS, WSL)
# Tries multiple PDF generation methods

set -e

echo "=== Building CV ==="
echo ""

# Try PDF generation with different engines
SUCCESS=0

# Try pdflatex first (most common)
if command -v pdflatex &> /dev/null; then
    echo "Using pdflatex..."
    pandoc example-cv.md --defaults=pdf.yaml -o example-cv.pdf
    SUCCESS=1
elif command -v xelatex &> /dev/null; then
    echo "Using xelatex..."
    pandoc example-cv.md --defaults=pdf.yaml --pdf-engine=xelatex -o example-cv.pdf
    SUCCESS=1
elif command -v wkhtmltopdf &> /dev/null; then
    echo "Using wkhtmltopdf..."
    # Generate HTML first, then convert to PDF
    pandoc example-cv.md --defaults=pdf.yaml -t html -o /tmp/cv-temp.html
    wkhtmltopdf /tmp/cv-temp.html example-cv.pdf
    rm -f /tmp/cv-temp.html
    SUCCESS=1
elif command -v weasyprint &> /dev/null; then
    echo "Using weasyprint..."
    # Generate HTML first, then convert to PDF
    pandoc example-cv.md --defaults=pdf.yaml -t html -o /tmp/cv-temp.html
    weasyprint /tmp/cv-temp.html example-cv.pdf
    rm -f /tmp/cv-temp.html
    SUCCESS=1
else
    echo "No PDF generation tool found!"
    echo ""
    echo "Please install one of the following:"
    echo "  - TeX Live (Linux): sudo apt install texlive texlive-latex-extra"
    echo "  - MiKTeX (Windows): https://miktex.org/"
    echo "  - wkhtmltopdf: https://wkhtmltopdf.org/"
    echo "  - weasyprint: pip install weasyprint"
    echo ""
    echo "Alternatively, generate HTML output:"
    echo "  pandoc example-cv.md --defaults=pdf.yaml -t html -o example-cv.html"
    exit 1
fi

if [ $SUCCESS -eq 1 ]; then
    echo ""
    echo "✓ Build successful! Output: example-cv.pdf"
fi
