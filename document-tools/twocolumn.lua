-- twocolumn.lua - Set up repeating header/footer from metadata, and wrap the
-- CV body in a two-column layout.
--
-- Contact details are read from the document's YAML metadata:
--   name, email, mobile, github, website, updated
--
-- The header stacks the name on its own line, with contact details on
-- one or two lines beneath it (so nothing overlaps on narrow margins).
--
-- If the body contains a horizontal rule (---), content BEFORE it stays
-- full-width (e.g. a summary section) and everything AFTER it is wrapped
-- in an UNBALANCED LaTeX multicols* environment: the first column fills
-- the page to the bottom before spilling into the second, like a
-- scientific paper's final page (no big gap between the columns' end
-- and the footer). With no rule, the whole body is two-column.

local function meta_string(doc, key, fallback)
  local v = doc.meta[key]
  if v == nil and fallback then
    v = doc.meta[fallback]
  end
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

function Pandoc(doc)
  -- Read contact details from metadata
  local name    = meta_string(doc, 'name',    'author')
  local email   = meta_string(doc, 'email',   nil)
  local mobile  = meta_string(doc, 'mobile',  'phone')
  local github  = meta_string(doc, 'github',   nil)
  local website = meta_string(doc, 'website', 'url')
  local updated = meta_string(doc, 'updated', nil)

  -- Collect contact entries with FontAwesome icons, wrapped in \href links.
  -- Note: pandoc already loads hyperref for us when colorlinks is set.
  local function link(target, body)
    if target == "" then return body end
    return "\\href{" .. target .. "}{" .. body .. "}"
  end

  local contacts = {}
  if email ~= "" then
    table.insert(contacts, link("mailto:" .. email, "\\faEnvelope\\ " .. email))
  end
  if mobile ~= "" then
    -- tel: links want digits only; strip spaces/parens/plus stays
    local tel = mobile:gsub("[^%d+]", "")
    table.insert(contacts, link("tel:" .. tel, "\\faMobile\\ " .. mobile))
  end
  if github ~= "" then
    -- accept either "github.com/user" or a full https URL
    local gh = github:match("^https?://") and github or "https://" .. github
    table.insert(contacts, link(gh, "\\faGithub\\ " .. github))
  end
  if website ~= "" then
    local url = website:match("^https?://") and website or "https://" .. website
    table.insert(contacts, link(url, "\\faGlobe\\ " .. website))
  end

  -- Header lines: name first, contacts split across up to two lines
  -- (roughly half the entries per line) so nothing overlaps.
  local header_lines = {}
  if name ~= "" then
    table.insert(header_lines, "{\\normalsize\\bfseries " .. name .. "}")
  end

  local n = #contacts
  if n > 0 then
    local half = math.ceil(n / 2)
    local first_half  = table.concat({ table.unpack(contacts, 1, half) }, " \\textbar{} ")
    local second_half = ""
    if n > half then
      second_half = table.concat({ table.unpack(contacts, half + 1, n) }, " \\textbar{} ")
    end
    table.insert(header_lines, "{\\small " .. first_half .. "}")
    if second_half ~= "" then
      table.insert(header_lines, "{\\small " .. second_half .. "}")
    end
  end

  local header_cmd = ""
  if #header_lines > 0 then
    header_cmd = "\\fancyhead[L]{\\begin{tabular}{@{}l@{}}"
      .. table.concat(header_lines, "\\\\")
      .. "\\end{tabular}}"
  end

  -- Footer: "Last updated" on the left, page number on the right
  local footer_left = ""
  if updated ~= "" then
    footer_left = "\\fancyfoot[L]{{\\footnotesize\\itshape " .. updated .. "}}"
  end

  -- Preamble: packages, page furniture, section typography.
  -- IMPORTANT: set as RawBlock inside MetaBlocks so pandoc passes the LaTeX
  -- through verbatim instead of escaping the backslashes.
  local preamble = table.concat({
    "\\usepackage[utf8]{inputenc}",
    "\\usepackage[T1]{fontenc}",
    "\\usepackage{fontawesome5}",
    "\\usepackage{longtable}",
    "\\usepackage{array}",
    "\\usepackage{graphicx}",
    "\\usepackage{fancyhdr}",
    "\\usepackage{multicol}",
    "\\usepackage{parskip}",
    "\\usepackage{enumitem}",
    "\\usepackage{booktabs}",
    "\\usepackage{titlesec}",
    "\\setlist{noitemsep,topsep=0pt,parsep=0pt,partopsep=0pt,leftmargin=*}",
    "\\setlength{\\columnsep}{0.9cm}",
    "\\setlength{\\columnseprule}{0.4pt}",
    "\\setlength{\\headheight}{46pt}",
    "\\setlength{\\footskip}{30pt}",
    "\\pagestyle{fancy}",
    "\\fancyhf{}",
    header_cmd,
    footer_left,
    "\\fancyfoot[R]{\\footnotesize Page \\thepage}",
    "\\renewcommand{\\headrulewidth}{0.4pt}",
    "\\renewcommand{\\footrulewidth}{0pt}",
    "\\titleformat{\\section}{\\normalsize\\bfseries\\uppercase}{\\thesection}{1em}{}",
    "\\titlespacing*{\\section}{0pt}{12pt}{4pt}",
    "\\titleformat{\\subsection}{\\normalsize\\bfseries}{\\thesubsection}{1em}{}",
    "\\titlespacing*{\\subsection}{0pt}{8pt}{2pt}",
    "\\definecolor{inlinecode}{HTML}{B03A5B}",
    "\\let\\oldtexttt\\texttt",
    "\\renewcommand{\\texttt}[1]{{\\color{inlinecode}\\oldtexttt{#1}}}"
  }, "\n")

  doc.meta['header-includes'] = pandoc.MetaBlocks{
    pandoc.RawBlock('latex', preamble)
  }

  -- Two-column layout ---------------------------------------------------------

  -- Find the first horizontal rule
  local split_index = nil
  for i, block in ipairs(doc.blocks) do
    if block.t == 'HorizontalRule' then
      split_index = i
      break
    end
  end

  -- No rule: wrap the entire body in two columns
  if not split_index then
    table.insert(doc.blocks, 1, pandoc.RawBlock('latex', '\n\\begin{multicols*}{2}\n'))
    table.insert(doc.blocks, pandoc.RawBlock('latex', '\n\\end{multicols*}\n'))
    return doc
  end

  -- Rule found: content before the rule stays full-width,
  -- content after the rule becomes two-column
  local before, after = {}, {}
  for i, block in ipairs(doc.blocks) do
    if i < split_index then
      table.insert(before, block)
    elseif i > split_index then
      table.insert(after, block)
    end
    -- the rule itself is dropped (the header rule separates visually)
  end

  local new_blocks = {}
  for _, block in ipairs(before) do
    table.insert(new_blocks, block)
  end
  if #after > 0 then
    table.insert(new_blocks, pandoc.RawBlock('latex', '\n\\begin{multicols*}{2}\n'))
    for _, block in ipairs(after) do
      table.insert(new_blocks, block)
    end
    table.insert(new_blocks, pandoc.RawBlock('latex', '\n\\end{multicols*}\n'))
  end

  doc.blocks = new_blocks
  return doc
end
