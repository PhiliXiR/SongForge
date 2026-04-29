# Workflow 01 - Intake and Generation

## Goal

Take a seed brief and produce a review-ready record containing concept options, selected concept, lyrics, prompt, and metadata.

## Trigger

- webhook
- manual test trigger
- optional chat-triggered task

## Steps

1. Receive payload
2. Normalize fields
3. Insert song record in Supabase
4. Call OpenClaw concept agent
5. Save concept options
6. Pause for concept selection or auto-select first concept for testing
7. Call lyric agent
8. Save lyrics
9. Call prompt agent
10. Save SUNO prompt
11. Call metadata agent
12. Save metadata
13. Update status to `ready_for_review`

## Required Inputs

```json
{
  "project": "night-drive",
  "seed_brief": "melancholic synth-pop song about missing someone you only knew online"
}
```

## Output

Updated song record in Supabase.

## Notes

For the first implementation, allow concept selection to be manual. Don't overcomplicate the decision gate.
