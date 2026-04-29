-- SongForge initial schema

create extension if not exists pgcrypto;

create table if not exists songs (
  id uuid primary key default gen_random_uuid(),
  song_id text unique,
  project text not null,
  status text not null default 'idea_submitted',
  seed_brief text not null,
  selected_concept text,
  concept_options jsonb not null default '[]'::jsonb,
  lyrics text,
  suno_prompt text,
  audio_url text,
  cover_art_prompt text,
  final_title text,
  title_options jsonb not null default '[]'::jsonb,
  genre_tags jsonb not null default '[]'::jsonb,
  mood_tags jsonb not null default '[]'::jsonb,
  short_description text,
  human_approved boolean,
  monetizable boolean,
  package_path text,
  distributor_status text,
  review_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists songs_status_idx on songs(status);
create index if not exists songs_project_idx on songs(project);
create index if not exists songs_created_at_idx on songs(created_at desc);

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists songs_set_updated_at on songs;
create trigger songs_set_updated_at
before update on songs
for each row
execute function set_updated_at();

comment on table songs is 'Primary SongForge workflow record';
comment on column songs.song_id is 'Human-friendly identifier, e.g. SF-0001';
comment on column songs.concept_options is 'Generated concept candidates';
comment on column songs.title_options is 'Generated title candidates';
