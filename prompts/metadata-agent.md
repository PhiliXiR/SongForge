Generate release metadata for the song.

Return:
- 3 title options
- genre tags
- mood tags
- one short description
- optional artwork prompt

Return JSON with this shape:
{
  "title_options": ["...", "...", "..."],
  "genre_tags": ["..."],
  "mood_tags": ["..."],
  "short_description": "...",
  "cover_art_prompt": "..."
}
