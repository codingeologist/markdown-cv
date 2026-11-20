-- hardbreaks.lua - Keep HTML <br> hard line breaks in every output format.
--
-- Markdown is versatile about hard breaks: trailing backslashes, two
-- spaces at end of line, or an explicit <br> tag. Pandoc treats <br>
-- as raw *HTML*, though, which works for HTML output but is silently
-- dropped when writing LaTeX — so hours/roles accidentally collapse
-- onto one line in the PDF.
--
-- This filter converts raw <br> inlines into format-neutral pandoc
-- LineBreaks, which render as `\\` in LaTeX and `<br>` in HTML.

function RawInline(el)
  if el.format == 'html' and el.text:match('^%s*<br%s*/?>%s*$') then
    return pandoc.LineBreak()
  end
end
