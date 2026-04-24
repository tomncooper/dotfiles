---
name: weekly-status
description: Use when the user asks for a weekly status update, status report, weekly summary, or what they worked on last week. Reads Obsidian diary entries for the last N days and produces a themed summary. Accepts optional number of days argument (default 7).
user-invocable: true
---

# Weekly Status Update

Generate a status update from Obsidian vault diary entries. Accepts an optional argument for the number of days to summarise (default: 7). Usage: `/weekly-status [days]` — e.g. `/weekly-status 14` for a two-week summary.

## Workflow

### Step 1: Parse argument and calculate date range

Parse the optional days argument. If a positive integer is provided, use it as N. Otherwise default to 7. Determine today's date. Compute the last N calendar days (today minus N-1 through today) as `YYYY-MM-DD` strings. Note which `YYYY/MM` month directories are needed — there may be multiple if the range spans month boundaries.

### Step 2: Discover diary files

For each month directory in the range, call `mcp__obsidian__list_directory` with path `Diary/YYYY/MM`. Filter returned filenames to only those matching dates in the N-day range. If the range spans multiple months, list all relevant directories.

### Step 3: Read diary entries

Build paths as `Diary/YYYY/MM/YYYY-MM-DD.md` for each file found. Call `mcp__obsidian__read_multiple_notes` with all paths (max 10 per batch — if N > 10, split into multiple calls). Set `includeFrontmatter: false`.

### Step 4: Filter content

Parse each entry's bullet points:
- **Include** regular bullets (`-`) and checked tasks (`- [x]`) — these are completed work.
- **Exclude** unchecked tasks (`- [ ]`) from the summary. However, collect any `- [ ]` items that have a `📅 YYYY-MM-DD` due date falling within the next 7 days (today+1 through today+7) for the "Next week" section.
- **Skip** empty or trivial entries (e.g., entries containing only `"- "`).

### Step 5: Resolve links

**GitHub links** — match pattern `https://github.com/[owner]/[repo]/(pull|issues)/[number]`:
- For each unique URL, run via Bash:
  - PRs: `gh pr view <URL> --json title,state --jq '"\\(.title) (\\(.state))"'`
  - Issues: `gh issue view <URL> --json title,state --jq '"\\(.title) (\\(.state))"'`
- Skip malformed links with empty hrefs like `[text]()`.
- If `gh` fails, fall back to WebFetch or include the raw link.
- Store the resolved title, state, and type (PR/issue) for use in Step 6 output formatting.

**Wikilinks** — match pattern `[[note-name]]`:
- Identify linked notes that are project/topic references (skip date references like `[[2026-04-01]]`).
- Read up to 5 unique linked notes via `mcp__obsidian__read_note`.
- Produce a 1-2 sentence summary of each linked note's content.

### Step 6: Compose output

**Last Week section:**
- Title: `## Last Week`
- Structure as a nested bullet list: top-level bullets are subject areas/themes, nested bullets are distinct tasks achieved within that subject area.
- Group by theme/project, not by day.
- Deduplicate: if the same activity spans multiple days, merge into one nested bullet describing the arc.
- **Link formatting rules** — use the resolved title and state as plain text in the bullet, with a short generic link label (`[PR](url)`, `[issue](url)`, `[doc](url)`) placed naturally:
  - Inline style (preferred): "Opened quickstart docs [PR](url), now merged"
  - Parenthetical style (when inline is awkward): "Reviewed the replication proposal ([issue](url))"
  - **Never** use the PR/issue title or number as the link text. The link text must be one of: `PR`, `issue`, `doc`.
  - **Never** put the link inside parentheses together with state — wrong: `([PR](url), merged)`. Right: "merged the quickstart docs [PR](url)" or "([PR](url)) which has been merged".
- For wikilinked notes, include a parenthetical summary on first reference.
- Use past tense. Keep nested bullets concise (1-2 sentences each). Aim for 8-15 total task bullets across all subject areas (scale up slightly for larger ranges).

**Next Week section (conditional):**
- If any `- [ ]` tasks with due dates in the next 7 days were found, add `## Next Week` after the Last Week section.
- List each task as a plain bullet (`-`), stripped of all Obsidian Tasks emoji (`⏫`, `🔼`, `📅`, `✅`, etc.) and date annotations. Output only the task description text.
- If no upcoming tasks were found, omit this section entirely.

### Step 7: Edit and copy to clipboard as rich text

After displaying the composed Markdown in the conversation:

1. Write the exact Markdown output from Step 6 to `/tmp/weekly-status.md` using the Write tool.
2. Tell the user to run the editor: suggest typing `! edit-and-copy-md` in the Claude Code prompt.
   - This opens gvim on the file. After the user saves and quits, the script converts to HTML and copies to clipboard.
   - Tell the user: "Edit in gvim, then :wq. HTML will be copied to clipboard. Use `:CopyHTML` inside gvim to re-copy without closing."
3. Do not delete `/tmp/weekly-status.md` — leave it for potential re-editing.

If `edit-and-copy-md` is not found, fall back to the direct pandoc pipeline:
`pandoc -f markdown -t html /tmp/weekly-status.md | wl-copy --type text/html`
and inform the user they can install the script for editing support.

If the pipeline fails (e.g., `wl-copy` cannot connect to a Wayland display), inform the user that clipboard copy failed and they can copy the Markdown from the conversation instead. Do not retry.

## Output template

```
## Last Week

- **Theme/Project Name**
  - Opened the quickstart docs [PR](url), now merged
  - Investigated flaky replication test ([issue](url)), root cause was a race condition
- **Another Theme**
  - Reviewed the upgrade guide [doc](url) and updated compatibility matrix
  - Activity with [[linked note]] context (brief summary)

## Next Week
- Task description without emoji or dates
- Another upcoming task
```

## Edge cases

- **Invalid argument**: If the argument is not a positive integer, ignore it and default to 7.
- **Cross-month range**: List all month directories when the N-day range spans boundaries.
- **Large N (> 30)**: Batch `read_multiple_notes` calls (max 10 per batch). Warn the user if many entries exist — output may be lengthy.
- **No entries found**: Tell the user no diary files exist for the range.
- **Empty entries**: Skip entries containing only whitespace or bare `"- "`.
- **gh CLI unavailable**: Fall back to WebFetch or include raw link without metadata.
- **No upcoming tasks**: Omit the "Next week" section entirely.
- **Clipboard unavailable**: If `wl-copy` fails (no Wayland session, SSH without display forwarding), inform the user and skip clipboard copy. The Markdown output in the conversation is still usable.
- **`edit-and-copy-md` not found**: Fall back to direct pandoc + wl-copy pipeline (no editor). Inform user the script is needed for editing.
- **gvim unavailable**: Same fallback — direct copy without editor.
- **User closes gvim without saving**: Pandoc converts the original unmodified file — correct behavior, original report gets copied.
- **Re-editing after close**: File stays at `/tmp/weekly-status.md`. User can reopen with `gvim /tmp/weekly-status.md` and use `:CopyHTML`.
