# Workflow 03 - Packaging

## Goal

Create a structured export folder for approved songs.

## Trigger

- song status becomes `approved`

## Files to Produce

- `lyrics.txt`
- `metadata.json`
- `release_notes.md`
- `audio.mp3` placeholder or copied file
- `artwork.png` placeholder or copied file

## Suggested Output Path

```text
/SONG_FACTORY/{project}/{song_id}/
```

## Notes

Packaging should be idempotent. Re-running it should update files cleanly rather than create duplicates.
