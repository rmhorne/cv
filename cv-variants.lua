-- Optional content that only some CV versions show.
-- Text marked [ ... ]{.dissertation} appears only when the version's
-- front matter sets `show-dissertation: true` (e.g. for ancient history jobs).
-- With `condense-ta: true`, a ::: {.ta-short} block replaces the full
-- ::: {.ta-full} list of teaching-assistant courses; otherwise the full list shows.

local show_dissertation = false
local condense_ta = false

local function read_meta(meta)
  show_dissertation = meta["show-dissertation"] == true
  condense_ta = meta["condense-ta"] == true
end

local function filter_span(el)
  if el.classes:includes("dissertation") and not show_dissertation then
    return {}
  end
end

-- Unwrap the kept block rather than leaving a Div, so its headings and entries
-- sit at the top level, where cv-entries.lua groups them for the PDF.
local function filter_div(el)
  if el.classes:includes("ta-short") then
    return condense_ta and el.content or {}
  end
  if el.classes:includes("ta-full") then
    return condense_ta and {} or el.content
  end
end

return {
  { Meta = read_meta },
  { Span = filter_span, Div = filter_div },
}
