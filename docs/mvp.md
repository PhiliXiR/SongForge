# SongForge MVP Plan

## Objective

Prove that SongForge can reliably move from a short brief to a structured, review-ready song record.

## MVP Success Criteria

A successful MVP can:
- ingest a brief
- generate multiple concepts
- save the selected concept
- generate lyrics and a SUNO prompt
- store outputs in Supabase
- create a folder/package skeleton for review
- support approve / reject / revise states

## MVP Inputs

Required input fields:
- project
- seed_brief

Optional fields:
- target genre
- reference artists
- mood tags
- vocal style
- tempo notes
- release priority

## MVP Outputs

For each song:
- concept text
- lyrics draft
- SUNO prompt
- title candidates
- mood/genre tags
- review status
- package folder

## MVP Workflow

### Step 1 - Intake
Create a song record with status `idea_submitted`.

### Step 2 - Concept Generation
Generate 3-5 concepts from the brief.
Human selects one.
Status -> `concept_selected`.

### Step 3 - Lyrics
Generate lyrics from selected concept.
Status -> `lyrics_generated`.

### Step 4 - SUNO Prompt
Create a structured generation prompt.
Status -> `prompt_generated`.

### Step 5 - Audio Generation
Initial MVP may keep this manual if no stable API exists.
Status -> `audio_pending` or `ready_for_review` depending on workflow.

### Step 6 - Review
Allow these actions:
- approve
- reject
- request revision

### Step 7 - Packaging
Create a package folder with:
- `lyrics.txt`
- `metadata.json`
- `release_notes.md`
- placeholder for `audio.mp3`
- placeholder for `artwork.png`

## Non-Goals

- automated publishing
- royalty analytics
- large multi-project UI
- mass batch scaling

## Recommendation

Use the MVP to optimize **decision quality**, not throughput. If the first five songs are messy, scaling just multiplies mess.
