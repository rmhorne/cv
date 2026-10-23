# cv

Ryan Horne's CV, built with [Quarto](https://quarto.org) as a web page and a PDF.

## Layout

- `index.qmd` is the CV itself: it pulls in each section file in order.
- One `.qmd` file per section (`education.qmd`, `publications.qmd`, …). Edit these.
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

## Building

```bash
quarto render
```

Output goes to `_output/`: `index.html` (self-contained) and `cv.pdf`. The PDF is built
with Typst, which ships with Quarto, so no LaTeX is needed. For a live preview while
editing:

```bash
quarto preview
```
