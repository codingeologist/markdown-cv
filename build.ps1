# Build script for Windows PowerShell
# Tries multiple PDF generation methods

Write-Host "=== Building CV ==="
Write-Host ""

$success = $false

# Try pdflatex first (most common)
if (Get-Command pdflatex -ErrorAction SilentlyContinue) {
    Write-Host "Using pdflatex..."
    pandoc example-cv.md --defaults=pdf.yaml -o example-cv.pdf
    if ($LASTEXITCODE -eq 0) {
        $success = $true
    }
}
# Try xelatex
elseif (Get-Command xelatex -ErrorAction SilentlyContinue) {
    Write-Host "Using xelatex..."
    pandoc example-cv.md --defaults=pdf.yaml --pdf-engine=xelatex -o example-cv.pdf
    if ($LASTEXITCODE -eq 0) {
        $success = $true
    }
}
# Try wkhtmltopdf
elseif (Get-Command wkhtmltopdf -ErrorAction SilentlyContinue) {
    Write-Host "Using wkhtmltopdf..."
    # Generate HTML first, then convert to PDF
    pandoc example-cv.md --defaults=pdf.yaml -t html -o $env:TEMP\cv-temp.html
    wkhtmltopdf $env:TEMP\cv-temp.html example-cv.pdf
    Remove-Item -Force $env:TEMP\cv-temp.html
    if ($LASTEXITCODE -eq 0) {
        $success = $true
    }
}
# Try weasyprint
elseif (Get-Command weasyprint -ErrorAction SilentlyContinue) {
    Write-Host "Using weasyprint..."
    # Generate HTML first, then convert to PDF
    pandoc example-cv.md --defaults=pdf.yaml -t html -o $env:TEMP\cv-temp.html
    weasyprint $env:TEMP\cv-temp.html example-cv.pdf
    Remove-Item -Force $env:TEMP\cv-temp.html
    if ($LASTEXITCODE -eq 0) {
        $success = $true
    }
}

if (-not $success) {
    Write-Host "No PDF generation tool found!`n"
    Write-Host "Please install one of the following:"
    Write-Host "  - MiKTeX (Windows): https://miktex.org/"
    Write-Host "  - TeX Live (WSL/Linux): sudo apt install texlive texlive-latex-extra"
    Write-Host "  - wkhtmltopdf: https://wkhtmltopdf.org/"
    Write-Host "  - weasyprint: pip install weasyprint`n"
    Write-Host "Alternatively, generate HTML output:"
    Write-Host "  pandoc example-cv.md --defaults=pdf.yaml -t html -o example-cv.html"
    exit 1
}

Write-Host "`nBuild successful! Output: example-cv.pdf"
