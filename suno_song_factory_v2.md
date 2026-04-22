# SUNO Song Factory Pipeline v2
## Full Implementation Pack (OpenClaw + n8n)

---

## 0. Purpose

This document is a **ready-to-build system blueprint** for launching a scalable AI music pipeline with:
- Structured workflows
- Approval gates
- Repeatable generation
- Release packaging

This is designed to go from **zero → working system fast**.

---

## 1. System Overview

### Stack

- OpenClaw → AI orchestration (ideas, lyrics, prompts, metadata)
- n8n → workflow engine (state, approvals, automation)
- Storage → Google Drive / local FS
- Database → Airtable / Supabase / Google Sheets
- Distributor → DistroKid / TuneCore / etc.

---

## 2. Project Setup Checklist

### Required

- [ ] n8n installed (local or cloud)
- [ ] OpenClaw running (local gateway confirmed)
- [ ] Storage location created (/SONG_FACTORY)
- [ ] Database created (table: songs)
- [ ] Paid SUNO plan active

---

## 3. Database Schema (Production Ready)

Fields:

- song_id (string)
- project (string)
- status (string)
- seed_brief (text)
- concept (text)
- lyrics (long text)
- prompt (text)
- audio_url (text)
- cover_art_prompt (text)
- final_title (text)
- human_approved (boolean)
- monetizable (boolean)
- package_path (text)
- distributor_status (string)
- created_at (datetime)
- updated_at (datetime)

---

## 4. OpenClaw Agent Prompts

### Concept Agent

"""
You are a music concept generator.

Input:
{seed_brief}

Output:
- 5 song concepts
- 1 sentence each
- Distinct vibes
"""

---

### Lyric Agent

"""
Write lyrics based on:
{concept}

Constraints:
- strong hook
- no filler lines
- emotionally clear
"""

---

### Prompt Agent

"""
Convert into SUNO prompt:

Include:
- genre
- mood
- instruments
- vocal style
- pacing
"""

---

### Metadata Agent

"""
Generate:
- title (3 options)
- genre
- mood tags
- short description
"""

---

## 5. n8n Workflow (Node-Level)

### Workflow 1: Intake

Nodes:
- Webhook Trigger
- Set Node (normalize input)
- HTTP Request → OpenClaw
- Function Node (parse response)
- DB Insert
- Notify (Slack/Email)

---

### Workflow 2: Generation Queue

Nodes:
- Cron Trigger
- DB Query (status = prompt_ready)
- IF Node
- HTTP / Manual trigger
- Update status

---

### Workflow 3: Review

Nodes:
- Trigger (audio ready)
- Send message (review card)
- Wait Node (webhook resume)

Branch:
- Reject → update status
- Revise → send to OpenClaw
- Approve → next stage

---

### Workflow 4: Packaging

Nodes:
- HTTP → OpenClaw (metadata)
- Create Folder
- Write Files
- Update DB

---

### Workflow 5: Distribution Task

Nodes:
- IF checks
- Create task entry
- Notify user

---

## 6. Review Message Template

Title: {working_title}

Concept: {concept}

Audio: {audio_url}

Options:
- REJECT
- REVISE
- APPROVE

---

## 7. File Outputs

Each approved song generates:

- audio.mp3
- lyrics.txt
- metadata.json
- release_notes.md
- artwork.png

---

## 8. Release Checklist

Before submission:

- [ ] Human approved
- [ ] Lyrics reviewed
- [ ] Title finalized
- [ ] Metadata clean
- [ ] Artwork exists
- [ ] Monetization allowed

---

## 9. MVP Timeline

Day 1:
- Setup n8n + OpenClaw

Day 2:
- Build intake + review workflows

Day 3:
- Add packaging

Day 4:
- Run first batch

---

## 10. Scaling Strategy

- Batch 5–10 songs per session
- Only release top 10–20%
- Track approval rate
- Iterate prompts

---

## 11. Future Additions

- Auto artwork generation
- Performance tracking
- Playlist targeting
- Social content automation

---

## 12. Philosophy

Automate everything except taste.

