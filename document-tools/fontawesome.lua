-- fontawesome.lua - Convert simple icon markers to FontAwesome LaTeX commands
--
-- Usage: Reference this filter in your pdf.yaml
--
-- In your markdown, use:
--   [fa-comments] email@email.com
--
-- This filter will convert them to:
--   \faComments email@email.com

local icon_map = {
  ["fa-comments"] = "\\faComments",
  ["fa-mobile"] = "\\faMobile",
  ["fa-github"] = "\\faGithub",
  ["fa-chrome"] = "\\faChrome",
  ["fa-envelope"] = "\\faEnvelope",
  ["fa-linkedin"] = "\\faLinkedin",
  ["fa-twitter"] = "\\faTwitter",
  ["fa-home"] = "\\faHome",
  ["fa-user"] = "\\faUser",
  ["fa-phone"] = "\\faPhone",
  ["fa-globe"] = "\\faGlobe",
}

function Str(str)
  -- Check if this is an icon marker like [fa-comments]
  local text = str.text
  if text:match("^%[fa%-%a+%]$") then
    local icon_name = text:match("^%[(fa%-%a+)%]$")
    if icon_map[icon_name:lower()] then
      return pandoc.RawInline('latex', icon_map[icon_name:lower()])
    end
  end
  return nil
end

function Link(link)
  -- Check if the link text is an icon marker
  if #link.content == 1 and link.content[1].t == "Str" then
    local text = link.content[1].text
    if icon_map[text:lower()] then
      -- Return the icon command followed by the target
      return pandoc.RawInline('latex', icon_map[text:lower()] .. " " .. link.target)
    end
  end
  return nil
end
