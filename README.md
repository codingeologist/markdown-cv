# MARKDOWN-CV

Write a CV in plain markdown, get a polished two-column PDF with a
repeating header/footer — no LaTeX anywhere in the CV file.

Generated with [pandoc](https://pandoc.org/) and a small set of Lua
filters, styled with LaTeX behind the scenes.

## Prerequisites

- [pandoc](https://pandoc.org/) 3.x
- A LaTeX distribution: [TeX Live](https://www.tug.org/texlive/)
  (Linux/macOS) or [MiKTeX](https://miktex.org/) (Windows)

See [INSTALL.md](INSTALL.md) for platform-specific notes.

## Build

Run from the repository root:

```bash
pandoc example-cv.md --defaults=pdf.yaml -o example-cv.pdf
```

Or use the convenience scripts:

```bash
./build.sh        # Linux / macOS / Git Bash
./build.ps1       # Windows PowerShell
```

## Write your own CV

1. Copy `example-cv.md` to `my-cv.md`
2. Edit the YAML metadata block (contact details)
3. Edit the content
4. Build:

```bash
pandoc my-cv.md --defaults=pdf.yaml -o my-cv.pdf
```

### Metadata block (header, footer & page setup)

Everything personal lives in the YAML metadata at the top of the
markdown file:

```yaml
---
name: "First Name Last Name"
email: "email@email.com"
mobile: "+44 (0) 7777 777 777"
github: "github.com/codingeologist"
linkedin: "linkedin.com/in/codingeologist"
website: "codingeologist.github.io"
updated: "Last updated: November 2026"
fontsize: "10pt"
geometry: "top=2.5cm,bottom=2cm,left=1.5cm,right=1.5cm,a4paper,headheight=46pt,footskip=30pt"
colorlinks: true
toc: false
---
```

`twocolumn.lua` builds the page furniture from these fields:

- **Header (every page)**: name on its own line (bold), then contact
  details grouped semantically on two lines beneath it — personal
  contacts (email, mobile) on the first, web links (GitHub, LinkedIn,
  website) on the second — each with a FontAwesome icon and a
  *clickable* link (`mailto:`, `tel:`, `https://`)
- **Footer (every page)**: `updated` text on the left, `Page N` on
  the right

The GitHub, LinkedIn and website values accept either bare domains
(`github.com/user`) or full URLs (`https://...`). Empty optional
fields are simply omitted from the header.

### Body content

Use normal markdown. The horizontal rule (`---`) controls the layout
split:

```markdown
## SUMMARY
Full-width section — spans both columns

---

## WORK EXPERIENCE
Everything after the rule flows in two columns,
like a scientific paper.
```

- Content **before** the first `---` stays full-width (great for the
  summary)
- Everything **after** it renders in two columns (0.9cm gap, thin
  dividing rule). Columns are **unbalanced**, like a scientific
  paper's final page: the first column fills the page to the bottom
  before spilling into the second, so there's no large gap between
  the content and the footer
- With **no** rule, the entire body is two-column

Standard CV sections like the example use skills lists, stacked
role/company/date lines, and bullet points. Where you need a hard
line break, write an explicit `<br>` — the `hardbreaks.lua` filter
keeps it working in *both* PDF and HTML output (plain pandoc drops
`<br>` in LaTeX):

```markdown
**Senior Data Scientist**<br>
*Tech Company Ltd*<br>
`2021-Present`

- Built and deployed ML models for customer segmentation
```

Stacking role, company and dates on separate lines (rather than one
pipe-separated line) keeps them from wrapping unpredictably inside
the narrow columns, regardless of how long the names are.

### FontAwesome icons

Anywhere in the body, use `[fa-*]` markers:

```markdown
[fa-envelope] email@example.com
```

Available: `fa-comments`, `fa-mobile`, `fa-github`, `fa-chrome`,
`fa-envelope`, `fa-linkedin`, `fa-twitter`, `fa-home`, `fa-user`,
`fa-phone`, `fa-globe`. Add more by extending `icon_map` in
`document-tools/fontawesome.lua` (icons come from the
[fontawesome5](https://ctan.org/pkg/fontawesome5) LaTeX package —
commands like `\faLinkedin`).

Tables in markdown are auto-sized to wrap within the page by
`table-widths.lua`.

## Project structure

```
markdown-cv/
├── build.sh / build.ps1    # Build scripts (bash / PowerShell)
├── pdf.yaml                 # Pandoc defaults: format, PDF engine, filter chain
├── example-cv.md            # Example CV (metadata + content)
├── example-cv.pdf           # Generated output
├── INSTALL.md               # Platform-specific installation guide
└── document-tools/
    ├── README.md            # Per-filter notes (see this for details)
    ├── hardbreaks.lua       # Keeps <br> hard line breaks in PDF & HTML
    ├── twocolumn.lua        # Header/footer from metadata + two-column layout
    ├── fontawesome.lua      # [fa-*] markers → \fa* icons
    └── table-widths.lua     # Auto-sized table columns
```

## Customisation notes

- **Page geometry / fonts**: edit `geometry`, `fontsize`,
  `mainfont`, `monofont` in your CV's metadata block
- **Column appearance**: in `document-tools/twocolumn.lua`, see the
  `\columnsep` (gap) and `\columnseprule` (dividing line) settings
- **Section typography**: also in `twocolumn.lua`'s preamble
  (`\titleformat`/`\titlespacing` commands)
