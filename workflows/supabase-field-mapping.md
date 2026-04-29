# Supabase Field Mapping for Workflow 01

## Insert Step

Insert these fields when the workflow begins:

| Input / Derived | Supabase field |
|---|---|
| generated song id | `song_id` |
| input project | `project` |
| initial status | `status` |
| input brief | `seed_brief` |

## Concept Update Step

| Source | Supabase field |
|---|---|
| parsed concept array | `concept_options` |
| literal value | `status = concept_generated` |

## Selected Concept Update Step

| Source | Supabase field |
|---|---|
| chosen concept summary | `selected_concept` |
| literal value | `status = concept_selected` |

## Lyrics Update Step

| Source | Supabase field |
|---|---|
| parsed lyrics | `lyrics` |
| literal value | `status = lyrics_generated` |

## Prompt Update Step

| Source | Supabase field |
|---|---|
| parsed SUNO prompt | `suno_prompt` |
| parsed genre tags | `genre_tags` |
| parsed mood tags | `mood_tags` |
| literal value | `status = prompt_generated` |

## Final Metadata Update Step

| Source | Supabase field |
|---|---|
| parsed title options | `title_options` |
| parsed genre tags | `genre_tags` |
| parsed mood tags | `mood_tags` |
| parsed description | `short_description` |
| parsed art prompt | `cover_art_prompt` |
| literal value | `status = ready_for_review` |

## Suggested Rule

Use the database row `id` or `song_id` consistently as your update key. Don’t mix both casually unless you enjoy avoidable workflow gremlins.
