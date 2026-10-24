-- Optional content that only some CV versions show.
-- Text marked [ ... ]{.dissertation} appears only when the version's
-- front matter sets `show-dissertation: true` (e.g. for ancient history jobs).

local show_dissertation = false

local function read_meta(meta)
  show_dissertation = meta["show-dissertation"] == true
end

local function filter_span(el)
  if el.classes:includes("dissertation") and not show_dissertation then
    return {}
  end
end

return {
  { Meta = read_meta },
  { Span = filter_span },
}
