# Shared document tools

Pandoc Lua filters shared by CV documents. Referenced from `pdf.yaml`
(in this order):

- `hardbreaks.lua`: converts markdown `<br>` tags into format-neutral
  pandoc LineBreaks so hard line breaks survive in *both* PDF and
  HTML output (plain pandoc drops `<br>` when writing LaTeX).
- `twocolumn.lua`: builds a repeating page header/footer from the
  document metadata (`name`, `email`, `mobile`, `github`, `website`,
  `updated`) and wraps the document body in an unbalanced LaTeX
  `multicols*` two-column layout (full-width content before the first
  horizontal rule, two columns after it).
- `fontawesome.lua`: converts `[fa-*]` icon markers to FontAwesome
  LaTeX commands (fontawesome5 package).
- `table-widths.lua`: sizes table columns for wrapped PDF output.
