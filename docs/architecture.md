# SongForge Architecture

## Goal

Create a repeatable pipeline that turns a short creative brief into a reviewable music package with human approval gates.

## System Components

### 1. Intake Layer
Accepts a seed brief such as:
- genre or style
- emotional tone
- lyrical theme
- target audience
- release/project grouping

Possible intake surfaces:
- n8n webhook
- lightweight web form
- direct OpenClaw command

### 2. Orchestration Layer
Handled by n8n.

Responsibilities:
- normalize input
- create a song record
- call OpenClaw generation steps
- advance statuses
- wait for human approval
- trigger packaging

### 3. Generation Layer
Handled by OpenClaw prompts.

Functions:
- concept generation
- lyric generation
- SUNO prompt generation
- metadata generation
- optional artwork prompt generation

### 4. State Layer
Handled by Supabase.

Supabase stores:
- song identity
- generation outputs
- workflow status
- approval state
- packaging path
- timestamps

### 5. Asset Layer
Stores generated files such as:
- lyrics
- metadata
- artwork
- release notes
- audio references or final files

## Recommended Status Flow

```text
idea_submitted
-> concept_generated
-> concept_selected
-> lyrics_generated
-> prompt_generated
-> audio_pending
-> ready_for_review
-> revise_requested | rejected | approved
-> packaged
-> queued_for_distribution
-> released
```

## Design Principles

1. **Human taste remains in the loop**
2. **One record per song concept lifecycle**
3. **Every workflow step should be resumable**
4. **Generated artifacts should be saved outside chat history**
5. **Avoid hidden state in prompts or operators' heads**

## MVP Boundary

For v1, skip:
- automated distributor submission
- advanced analytics
- social content automation
- multi-user permissions
- large dashboard work

## Primary Unknowns

### SUNO Access Path
This is the biggest architecture variable.

Possible modes:
1. direct API
2. manual operator generation step
3. browser automation

The rest of the system should be designed so this step can be swapped later.

### Review Surface
Review can happen in:
- a database view
- n8n approval callback
- lightweight internal UI
- chat-driven approval

Recommendation: start with the least custom surface possible.
