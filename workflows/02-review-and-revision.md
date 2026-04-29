# Workflow 02 - Review and Revision

## Goal

Let a human approve, reject, or request revision on a generated song package.

## Trigger

- record reaches `ready_for_review`
- manual re-entry after revision request

## Review Actions

- `approve`
- `reject`
- `revise_lyrics`
- `revise_prompt`
- `revise_metadata`

## State Changes

- approve -> `approved`
- reject -> `rejected`
- revise -> corresponding generation step reruns, then return to `ready_for_review`

## Notes

Store revision notes in `review_notes` so requests are durable and not trapped in chat history.
