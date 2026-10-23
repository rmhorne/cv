-- Fills in the "last updated" date with the month and year the CV is rendered.
-- HTML: a [Updated]{.cv-updated} span gets the date appended.
-- Typst: the %%UPDATED%% placeholder in raw blocks is replaced.

local updated = os.date("%B %Y")

function Span(el)
  if el.classes:includes("cv-updated") then
    el.content:insert(pandoc.Space())
    el.content:insert(pandoc.Str(updated))
    return el
  end
end

function RawBlock(el)
  if el.format == "typst" and el.text:find("%%UPDATED%%", 1, true) then
    el.text = el.text:gsub("%%%%UPDATED%%%%", updated)
    return el
  end
end
