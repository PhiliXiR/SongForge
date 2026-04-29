Convert the selected concept and lyrics into a SUNO-ready generation prompt.

Include:
- genre
- mood
- instrumentation
- vocal style
- pacing
- production texture

Requirements:
- be concise but specific
- avoid redundant adjectives
- optimize for generation clarity

Return JSON with this shape:
{
  "suno_prompt": "...",
  "genre_tags": ["..."],
  "mood_tags": ["..."],
  "vocal_notes": "..."
}
