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

-- Keep dates like "January 3–6" on one line: a word joiner after an en dash
-- between digits, and each month with its day in an unbreakable box (Typst
-- 0.10 still breaks at a non-breaking space).
local WORD_JOINER = "\u{2060}"
local MONTHS = {
  "January", "February", "March", "April", "May", "June", "July",
  "August", "September", "October", "November", "December",
}

local function to_typst(inlines)
  local out = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), "typst",
    { wrap_text = "none" })
  -- "\1" stands in for the space inside a box, so a boxed range isn't
  -- boxed again by the single-day pass; it's restored at the end.
  for _, month in ipairs(MONTHS) do
    out = out:gsub(month .. " (%d+)–(%d+)", "#box[" .. month .. "\1%1–%2]")
    out = out:gsub(month .. " (%d+)", "#box[" .. month .. "\1%1]")
  end
  out = out:gsub("(%d)–(%d)", "%1–" .. WORD_JOINER .. "%2")
  return (out:gsub("\1", " "))
end

function Para(el)
  local date, body = split_entry(el.content)
  if not date then return nil end

  if quarto.doc.is_format("typst") then
    return pandoc.RawBlock("typst", string.format(
      "#block(breakable: false, above: 0.85em, below: 0.85em, grid(columns: (7.5em, 1fr), gutter: 0.8em, [%s], [%s]))",
      to_typst(date), to_typst(body)))
  end

  return pandoc.Div({
    pandoc.Div({ pandoc.Plain(date) }, { class = "cv-date" }),
    pandoc.Div({ pandoc.Plain(body) }, { class = "cv-body" }),
  }, { class = "cv-entry" })
end

-- In the PDF, keep a short subsection (its heading plus up to MAX_GROUP
-- entries) on one page, so a block like a university's teaching list
-- never starts a page without its heading. Longer lists may still break.
local MAX_GROUP = 6

local function typst_heading(h)
  return pandoc.write(pandoc.Pandoc({ h }), "typst", { wrap_text = "none" })
end

local function keep_groups(doc)
  if not quarto.doc.is_format("typst") then return nil end
  local out, blocks, i = pandoc.List(), doc.blocks, 1
  while i <= #blocks do
    local b = blocks[i]
    if b.t == "Header" and b.level == 3 then
      local j, entries = i + 1, pandoc.List()
      while j <= #blocks and blocks[j].t == "RawBlock" and blocks[j].format == "typst" do
        entries:insert(blocks[j].text); j = j + 1
      end
      if #entries > 0 and #entries <= MAX_GROUP then
        out:insert(pandoc.RawBlock("typst",
          "#block(breakable: false)[\n" .. typst_heading(b) .. "\n" .. table.concat(entries, "\n") .. "\n]"))
        i = j
      else
        out:insert(b); i = i + 1
      end
    else
      out:insert(b); i = i + 1
    end
  end
  doc.blocks = out
  return doc
end

return {
  { Para = Para },
  { Pandoc = keep_groups },
}
