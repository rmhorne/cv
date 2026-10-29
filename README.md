# cv

Ryan Horne's CV, built with [Quarto](https://quarto.org) as a web page and a PDF.

## Layout

- `index.qmd` is the main CV: it pulls in each section file in order.
- `cv-pomona.qmd` is a tailored version that includes the same section files in a
  different order (teaching first, then publications and projects) and a condensed
  teaching-assistant list.
- One `.qmd` file per section (`education.qmd`, `publications.qmd`,
  `digital-projects.qmd`, …). Edit these; every version picks up the change.
- `header.qmd` holds the name and contact block (separate HTML and PDF versions).
- `cv-entries.lua` turns any paragraph that starts with a date (`2021: …`,
  `2017 - 2019: …`, `2012-Present: …`) into a two-column entry, date on the left.
- `cv.css` styles the web version; `_quarto.yml` holds the project settings.

## Adding an entry

Write it as its own paragraph (blank line before and after), starting with the date and
a colon:

```markdown
2025: “Title of Talk”, Venue, City, Month Day
```

To reorder sections, change the order of the `include` lines in `index.qmd`.

## Tailored versions

To make a version for a particular job, copy `cv-pomona.qmd`, reorder its `include`
lines, give it its own `output-file`, and add it to the `render` list in
`_quarto.yml`. Each version still draws on the same section files, so there is only
one copy of the content.

Some text appears only in versions that ask for it. The dissertation title in
`education.qmd` is marked `[...]{.dissertation}` and is hidden unless a version's front
matter sets `show-dissertation: true` (useful for ancient history jobs). Setting
`condense-ta: true` replaces the full list of teaching-assistant courses in
`teaching.qmd` (the `::: {.ta-full}` block) with a two-line summary (the
`::: {.ta-short}` block); the Pomona version does this. Both switches are handled by
`cv-variants.lua`.

## Building

```bash
quarto render
```

Output goes to `_output/`: `index.html` (self-contained), `cv.pdf`, and one PDF per
tailored version (e.g. `cv-pomona.pdf`). The PDF is built
with Typst, which ships with Quarto, so no LaTeX is needed. For a live preview while
editing:

```bash
quarto preview
```
