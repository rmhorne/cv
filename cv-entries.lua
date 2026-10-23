-- Turns CV entries written as "DATE: text" into a two-column layout:
-- the date in a fixed left column, the entry text beside it.
-- e.g. "2017 - 2019: Post-Doctoral Fellow, ..." or "2012-Present: Pleiades Project"
-- A publication status ("Under review: ...") also goes in the date column.

local MAX_DATE_LEN = 24

local STATUSES = {
  ["under review"] = true,
  ["submitted"] = true,
  ["accepted"] = true,
  ["forthcoming"] = true,
  ["in press"] = true,
}

-- Returns the index of the inline that ends the date (the one ending in ":"),
-- or nil if the paragraph doesn't start with a date.
local function find_date_end(inlines)
  local text = ""
  for i, el in ipairs(inlines) do
    if el.t == "Str" then
      text = text .. el.text
      if el.text:sub(-1) == ":" then
        if text:match("%d%d%d%d") or STATUSES[text:sub(1, -2):lower()] then return i end
        return nil
      end
    elseif el.t == "Space" then
      text = text .. " "
    else
      return nil
    end
    if #text > MAX_DATE_LEN then return nil end
  end
  return nil
end

local function split_entry(inlines)
  local date_end = find_date_end(inlines)
  if not date_end then return nil end

  local date = pandoc.List()
  for i = 1, date_end do date:insert(inlines[i]) end
  local last = date[#date]
  date[#date] = pandoc.Str(last.text:sub(1, -2))

  local body = pandoc.List()
  for i = date_end + 1, #inlines do body:insert(inlines[i]) end
  while #body > 0 and (body[1].t == "Space" or body[1].t == "SoftBreak") do
    body:remove(1)
  end
  return date, body
end

local function to_typst(inlines)
  return pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), "typst")
end

function Para(el)
  local date, body = split_entry(el.content)
  if not date then return nil end

  if quarto.doc.is_format("typst") then
    return pandoc.RawBlock("typst", string.format(
      "#block(breakable: false, above: 0.95em, below: 0.95em, grid(columns: (7.5em, 1fr), gutter: 0.8em, [%s], [%s]))",
      to_typst(date), to_typst(body)))
  end

  return pandoc.Div({
    pandoc.Div({ pandoc.Plain(date) }, { class = "cv-date" }),
    pandoc.Div({ pandoc.Plain(body) }, { class = "cv-body" }),
  }, { class = "cv-entry" })
end
