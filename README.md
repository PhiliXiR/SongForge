# SongForge

SongForge is an AI-assisted music production pipeline for turning rough ideas into reviewable song packages.

## Current State

This repository is now scaffolded as a **build-ready planning repo**. It is not a running app yet. The goal of this structure is to make implementation straightforward without prematurely committing to the wrong UI or backend.

## Recommended MVP

Build the thinnest useful loop first:

1. Submit a `seed_brief`
2. Generate 3-5 concepts
3. Select one concept
4. Generate lyrics
5. Generate a SUNO prompt
6. Save everything to the database
7. Mark the song `ready_for_review`

Do **not** start with distribution automation. Automate everything except taste.

## Proposed Stack

- **OpenClaw**: concept, lyrics, prompt, and metadata generation
- **n8n**: orchestration, approvals, state transitions
- **Supabase**: source-of-truth database
- **Local filesystem / cloud storage**: generated assets and release packages

## Repository Structure

```text
SongForge/
├─ docs/                 # architecture, MVP, decisions
├─ prompts/              # agent prompt templates
├─ schema/               # database schema and seed definitions
├─ storage-template/     # expected output/package layout
├─ workflows/            # n8n workflow specs and implementation notes
├─ README.md
├─ .env.example
└─ suno_song_factory_v2.md   # original blueprint
```

## Next Build Order

### Phase 1 - Core data + prompts
- Finalize schema in `schema/supabase.sql`
- Adjust prompt templates in `prompts/`
- Decide how SUNO generation is triggered and tracked

### Phase 2 - First workflow
- Implement `workflows/01-intake-and-generation.md`
- Build a single end-to-end n8n flow
- Persist song records in Supabase

### Phase 3 - Review loop
- Implement approval / revise / reject state transitions
- Add packaging output folder generation

### Phase 4 - Optional operator UI
- Add a small dashboard only if workflow-only operation feels painful

## Key Risks To Validate Early

1. **Suno integration path** - API, manual handoff, or browser automation
2. **Approval UX** - where review decisions happen
3. **Storage layout** - local-first vs cloud-first asset management
4. **Metadata quality** - titles, tags, and packaging consistency

## Suggested Immediate Tasks

- Confirm whether SUNO has a reliable programmatic integration path for this project
- Stand up Supabase and create the `songs` table
- Build the first n8n intake workflow
- Test one full record from brief -> concept -> lyrics -> prompt -> review-ready
