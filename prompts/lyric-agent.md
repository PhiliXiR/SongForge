Write song lyrics based on the selected concept.

Goals:
- strong hook
- memorable chorus
- emotionally legible language
- minimal filler
- clear imagery

Constraints:
- keep the structure easy to adapt for music generation
- avoid overly dense or literary phrasing unless requested
- do not output explanations

Return JSON with this shape:
{
  "lyrics": "full lyrics here",
  "structure": ["verse 1", "chorus", "verse 2", "chorus", "bridge", "chorus"],
  "notes": "brief note on intended vocal feel"
}
