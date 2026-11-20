-- table-widths.lua — force pandoc's LaTeX writer to wrap table columns.
--
-- With minimal `|---|---|` separators, pandoc emits longtable columns with
-- unconstrained widths, so long cell content overflows the page. This filter
-- assigns each column a width proportional to its longest cell (floored and
-- clamped), so every table wraps inside the text width.
--
-- Usage: pandoc input.md -f gfm --lua-filter=table-widths.lua -o out.pdf

local stringify = require 'pandoc.utils'.stringify

local function scan_rows(rows, maxlen)
  for _, row in ipairs(rows) do
    for i, cell in ipairs(row.cells) do
      -- pandoc 3.1.x: stringify needs the Cell's content (blocks), not the Cell
      local len = #stringify(cell.content)
      if len > (maxlen[i] or 0) then maxlen[i] = len end
    end
  end
end

function Table(t)
  local ncols = #t.colspecs
  if ncols == 0 then return t end

  local maxlen = {}
  scan_rows(t.head.rows, maxlen)
  -- pandoc 3.1.x: TableBody = {head, body, ...} — the rows live in .body
  -- (renamed to .rows in later pandoc versions; support both)
  for _, body in ipairs(t.bodies) do
    scan_rows(body.body or body.rows or {}, maxlen)
    scan_rows(body.head or {}, maxlen)
  end

  -- proportional weights with a floor so narrow columns (e.g. "#") stay sane
  local weights, total = {}, 0
  for i = 1, ncols do
    weights[i] = math.max(maxlen[i] or 8, 8)
    total = total + weights[i]
  end

  -- clamp any column at 55% of the table, then renormalise
  for i = 1, ncols do
    weights[i] = math.min(weights[i] / total, 0.55)
  end
  local s = 0
  for i = 1, ncols do s = s + weights[i] end
  for i = 1, ncols do
    t.colspecs[i] = {t.colspecs[i][1], weights[i] / s}
  end
  return t
end
