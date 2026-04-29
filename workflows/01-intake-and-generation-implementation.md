# Workflow 01 Implementation - Intake and Generation

This document turns the high-level workflow into a concrete n8n implementation plan.

## Goal

Accept a song brief and produce a fully populated song record with:
- concept options
- selected concept
- lyrics
- SUNO prompt
- metadata
- status = `ready_for_review`

---

## Recommended MVP Trigger

Start with a **Manual Trigger** in n8n for rapid testing.
After that, add a **Webhook Trigger**.

---

## Input Contract

### Example Input

```json
{
  "project": "night-drive",
  "seed_brief": "melancholic synth-pop song about missing someone you only knew online",
  "genre_hint": "synth-pop",
  "mood_hint": ["melancholic", "nostalgic"],
  "reference_artists": ["The Midnight", "CHVRCHES"],
  "auto_select_first_concept": true
}
```

### Required fields
- `project`
- `seed_brief`

### Optional fields
- `genre_hint`
- `mood_hint`
- `reference_artists`
- `auto_select_first_concept`

---

## Node-by-Node Design

## 1. Manual Trigger

Use this for initial development.

Later replacement/addition:
- Webhook Trigger

---

## 2. Set - Normalize Input

### Purpose
Normalize incoming fields and ensure all expected keys exist.

### Output shape
```json
{
  "project": "night-drive",
  "seed_brief": "melancholic synth-pop song about missing someone you only knew online",
  "genre_hint": "synth-pop",
  "mood_hint": ["melancholic", "nostalgic"],
  "reference_artists": ["The Midnight", "CHVRCHES"],
  "auto_select_first_concept": true,
  "status": "idea_submitted"
}
```

### Notes
- Default `auto_select_first_concept` to `true` for MVP tests.
- If arrays come in as strings, normalize them here or in a Code node.

---

## 3. Code - Generate Song ID

### Purpose
Create a friendly human-readable ID like `SF-20260428-001`.

### Suggested logic
- prefix: `SF`
- date segment: `YYYYMMDD`
- short sequence or random suffix

### Example output
```json
{
  "song_id": "SF-20260428-A1F3"
}
```

### Example JS
```javascript
const now = new Date();
const yyyy = now.getFullYear();
const mm = String(now.getMonth() + 1).padStart(2, '0');
const dd = String(now.getDate()).padStart(2, '0');
const rand = Math.random().toString(36).slice(2, 6).toUpperCase();
return [{ json: { ...$json, song_id: `SF-${yyyy}${mm}${dd}-${rand}` } }];
```

---

## 4. Supabase - Insert Song Record

### Purpose
Create the base song record before generation begins.

### Table
`songs`

### Fields to insert
- `song_id`
- `project`
- `status`
- `seed_brief`

Optional:
- initialize `genre_tags` and `mood_tags` as arrays if desired

### Expected inserted status
`idea_submitted`

---

## 5. HTTP Request - OpenClaw Concept Agent

### Purpose
Generate 3-5 concept candidates.

### Request target
Your OpenClaw endpoint or gateway wrapper.

### Suggested request payload
```json
{
  "task": "Generate song concepts from this brief and return JSON only.",
  "prompt_template": "concept-agent",
  "inputs": {
    "seed_brief": "={{ $json.seed_brief }}",
    "genre_hint": "={{ $json.genre_hint }}",
    "mood_hint": "={{ $json.mood_hint }}",
    "reference_artists": "={{ $json.reference_artists }}"
  }
}
```

### Important
Whatever endpoint you use, make sure it returns structured JSON, not chatty prose.

---

## 6. Code - Parse Concept Response

### Purpose
Validate and normalize concept output.

### Expected input shape
```json
{
  "concepts": [
    { "title": "Neon Ghost", "summary": "..." },
    { "title": "Late Typing", "summary": "..." }
  ]
}
```

### Actions
- ensure `concepts` exists
- ensure array length > 0
- trim strings
- optionally limit to top 5

### Failure behavior
If malformed:
- set status to `generation_error`
- optionally stop workflow

---

## 7. Supabase - Update Concept Options

### Fields to update
- `concept_options`
- `status` = `concept_generated`

---

## 8. IF - Auto Select First Concept?

### Condition
`auto_select_first_concept === true`

### True path
Continue automatically using first concept.

### False path
Pause for manual selection.

For MVP, I’d keep `true` on until the pipeline works.

---

## 9A. Code - Select First Concept (MVP path)

### Purpose
Set:
- `selected_concept`
- `selected_title_seed`

### Example
```javascript
const first = $json.concept_options?.[0] || $json.concepts?.[0];
if (!first) throw new Error('No concept available to select');
return [{
  json: {
    ...$json,
    selected_concept: first.summary,
    selected_title_seed: first.title
  }
}];
```

---

## 9B. Wait / Manual Review Path (future)

For non-auto selection, use one of:
- Wait node resumed by webhook
- update record and let operator choose in database/UI
- chat-driven approval flow

This can wait until after the automatic path works.

---

## 10. Supabase - Update Selected Concept

### Fields
- `selected_concept`
- `status` = `concept_selected`

---

## 11. HTTP Request - OpenClaw Lyric Agent

### Purpose
Generate lyrics from the selected concept.

### Suggested payload
```json
{
  "task": "Write lyrics from the selected concept and return JSON only.",
  "prompt_template": "lyric-agent",
  "inputs": {
    "seed_brief": "={{ $json.seed_brief }}",
    "selected_concept": "={{ $json.selected_concept }}",
    "genre_hint": "={{ $json.genre_hint }}",
    "mood_hint": "={{ $json.mood_hint }}"
  }
}
```

---

## 12. Code - Parse Lyrics Response

### Expected shape
```json
{
  "lyrics": "...",
  "structure": ["verse 1", "chorus"],
  "notes": "..."
}
```

### Actions
- validate `lyrics`
- flatten structure if needed
- retain `notes` for optional logging

---

## 13. Supabase - Update Lyrics

### Fields
- `lyrics`
- `status` = `lyrics_generated`

---

## 14. HTTP Request - OpenClaw Prompt Agent

### Purpose
Create a SUNO-ready prompt.

### Suggested payload
```json
{
  "task": "Create a SUNO prompt from the song concept and lyrics. Return JSON only.",
  "prompt_template": "prompt-agent",
  "inputs": {
    "selected_concept": "={{ $json.selected_concept }}",
    "lyrics": "={{ $json.lyrics }}",
    "genre_hint": "={{ $json.genre_hint }}",
    "mood_hint": "={{ $json.mood_hint }}"
  }
}
```

---

## 15. Code - Parse Prompt Response

### Expected shape
```json
{
  "suno_prompt": "...",
  "genre_tags": ["synth-pop"],
  "mood_tags": ["melancholic", "nostalgic"],
  "vocal_notes": "airy female vocal"
}
```

### Actions
- validate `suno_prompt`
- normalize arrays

---

## 16. Supabase - Update Prompt Data

### Fields
- `suno_prompt`
- `genre_tags`
- `mood_tags`
- `status` = `prompt_generated`

---

## 17. HTTP Request - OpenClaw Metadata Agent

### Purpose
Generate title options and release metadata.

### Suggested payload
```json
{
  "task": "Generate release metadata and return JSON only.",
  "prompt_template": "metadata-agent",
  "inputs": {
    "selected_concept": "={{ $json.selected_concept }}",
    "lyrics": "={{ $json.lyrics }}",
    "suno_prompt": "={{ $json.suno_prompt }}"
  }
}
```

---

## 18. Code - Parse Metadata Response

### Expected shape
```json
{
  "title_options": ["Neon Ghost", "Typing In Blue", "Last Seen Online"],
  "genre_tags": ["synth-pop"],
  "mood_tags": ["melancholic", "nostalgic"],
  "short_description": "A late-night synth-pop ache about digital intimacy and distance.",
  "cover_art_prompt": "..."
}
```

### Actions
- validate title options
- merge tags carefully if already present
- allow metadata to refine earlier tag guesses

---

## 19. Supabase - Final Update

### Fields
- `title_options`
- `genre_tags`
- `mood_tags`
- `short_description`
- `cover_art_prompt`
- `status` = `ready_for_review`

---

## 20. Optional - Notify Operator

Use your preferred channel to signal:
- song ID
- project
- top title option
- status = `ready_for_review`

For MVP, this can be skipped if you are testing directly in Supabase.

---

## Error Handling Recommendation

For each OpenClaw call:
- enable continue-on-fail only if you capture errors explicitly
- write failure detail into a log table or execution notes
- update `songs.status` to one of:
  - `concept_error`
  - `lyrics_error`
  - `prompt_error`
  - `metadata_error`

If you want the main table to stay cleaner, add a separate `song_events` table later.

---

## Suggested Minimal n8n Nodes

```text
Manual Trigger
-> Set (Normalize Input)
-> Code (Generate Song ID)
-> Supabase (Insert Song)
-> HTTP Request (Concept Agent)
-> Code (Parse Concepts)
-> Supabase (Update Concepts)
-> IF (Auto Select?)
   -> Code (Select First Concept)
   -> Supabase (Update Selected Concept)
   -> HTTP Request (Lyric Agent)
   -> Code (Parse Lyrics)
   -> Supabase (Update Lyrics)
   -> HTTP Request (Prompt Agent)
   -> Code (Parse Prompt)
   -> Supabase (Update Prompt)
   -> HTTP Request (Metadata Agent)
   -> Code (Parse Metadata)
   -> Supabase (Final Update)
   -> Optional Notify
```

---

## Expression / Mapping Notes

Useful n8n expressions:
- `{{ $json.seed_brief }}`
- `{{ $json.selected_concept }}`
- `{{ $json.lyrics }}`
- `{{ $json.song_id }}`

Be disciplined about naming. A tiny naming mess in n8n becomes a giant headache later.

---

## MVP Advice

1. Build with **Manual Trigger** first
2. Keep **auto-select first concept = true** initially
3. Don’t solve review UX yet
4. Get one clean record all the way to `ready_for_review`
5. Only then add webhook intake and human concept selection

That order will save you a lot of thrashing.
