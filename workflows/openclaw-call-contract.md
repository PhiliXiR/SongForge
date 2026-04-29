# OpenClaw HTTP Call Contract for SongForge

This document describes how to call OpenClaw from n8n (or any HTTP client) to run agent turns for concept, lyric, prompt, and metadata generation.

## Assumptions

- You have an OpenClaw Gateway running and accessible from n8n.
- The Gateway's OpenAI-compatible chat completions endpoint is enabled (`gateway.http.endpoints.chatCompletions.enabled: true`).
- You are using shared-secret authentication (token or password) – the simplest for local/dev.
- You will use the **default agent** (`openclaw/default`) and steer behavior via the prompt.
- If you prefer dedicated agents, you can replace `openclaw/default` with `openclaw/<agentId>` after creating agents for each role.

## Endpoint

```
POST <gateway-host>:<gateway-port>/v1/chat/completions
```

Example local dev: `http://127.0.0.1:18789/v1/chat/completions`

## Authentication

### Shared-secret (token or password)

```
Authorization: Bearer <your-gateway-token-or-password>
```

If your gateway uses `gateway.auth.mode="token"`, set `gateway.auth.token` (or env `OPENCLAW_GATEWAY_TOKEN`).

If `gateway.auth.mode="password"`, use `gateway.auth.password`.

## Request Headers

| Header | Required? | Value |
|--------|-----------|-------|
| Authorization | Yes | `Bearer <token>` |
| Content-Type | Yes | `application/json` |
| (Optional) `x-openclaw-model` | No | Override the backend model for the selected agent, e.g. `openai/gpt-5.4` |
| (Optional) `x-openclaw-session-key` | No | If you want to reuse a session across calls (not needed for stateless prompts) |
| (Optional) `x-openclaw-message-channel` | No | Set synthetic ingress channel (e.g. `webchat`) if your prompts are channel-aware |

## Request Body

```json
{
  "model": "openclaw/default",
  "messages": [
    {
      "role": "user",
      "content": "<YOUR PROMPT HERE>"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 1000,
  "stream": false
}
```

### Prompt Construction

For each agent type, fill `<YOUR PROMPT HERE>` with the rendered prompt template from `prompts/`:

- **Concept Agent**: use `prompts/concept-agent.md` with inputs: `seed_brief`, `genre_hint`, `mood_hint`, `reference_artists`
- **Lyric Agent**: use `prompts/lyric-agent.md` with inputs: `selected_concept` (plus optional hints)
- **Prompt Agent**: use `prompts/prompt-agent.md` with inputs: `selected_concept`, `lyrics`
- **Metadata Agent**: use `prompts/metadata-agent.md` with inputs: `selected_concept`, `lyrics`, `suno_prompt`

### Expected Response Shape

On success (`200 OK`):

```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "created": <timestamp>,
  "model": "openclaw/default",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "<THE GENERATED TEXT>"
      },
      "finish_reason": "stop" | "length" | ...
    }
  ],
  "usage": { ... }
}
```

Extract the generated text from `choices[0].message.content`.

We expect the agent to return **JSON-only** (as per the prompt templates). If the agent returns extra chatter, you may need to add a parsing step in n8n to isolate the JSON blob.

### Error Handling

Non-200 responses will contain an error object in the body. Common issues:

- 401: invalid or missing auth
- 404: endpoint not enabled or wrong path
- 429: rate limited
- 500: internal error (check gateway logs)

## Example curl (Concept Agent)

```bash
curl -sS http://127.0.0.1:18789/v1/chat/completions \
  -H 'Authorization: Bearer ***' \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "openclaw/default",
    "messages": [
      {
        "role": "user",
        "content": "You are a music concept generator.\n\nInput:\n- seed_brief: melancholic synth-pop song about missing someone you only knew online\n- genre_hint: synth-pop\n- mood_hint: [\"melancholic\", \"nostalgic\"]\n- reference_artists: [\"The Midnight\", \"CHVRCHES\"]\n\nOutput requirements:\n- produce 5 distinct song concepts\n- one short paragraph each\n- each concept should feel commercially and emotionally clear\n- avoid filler and vague abstractions\n- include a short working title for each concept\n\nReturn JSON with this shape:\n{\n  \"concepts\": [\n    {\n      \"title\": \"...\",\n      \"summary\": \"...\"\n    }\n  ]\n}\n"
      }
    ],
    "temperature": 0.7,
    "max_tokens": 1000,
    "stream": false
  }'
```

## n8n HTTP Request Node Configuration

In n8n, configure an **HTTP Request** node as follows:

- **Method**: POST
- **URL**: `http://<gateway-host>:<gateway-port>/v1/chat/completions`
- **Authentication**: Header Auth → Name: `Authorization`, Value: `Bearer {{$env.gateway_token}}` (or set in credentials)
- **Headers**: Add `Content-Type: application/json`
- **Body**: JSON → Raw → Insert the JSON body above, using expressions for dynamic fields:
  - `"model": "openclaw/default"`
  - `"messages": [{ "role": "user", "content": "={{ $json.prompt }}" }]` where `$json.prompt` is the rendered template from a prior Set or Code node.
  - Optionally set temperature, max_tokens, stream.

### Tips

- Use a **Set** node before the HTTP Request to render the prompt via template strings or a small JavaScript function.
- After the HTTP Request, add a **Code** node to extract `{{ $json.choices[0].message.content }}` and parse it as JSON (if the agent returned pure JSON).
- If the agent output includes markdown code fences, strip them before parsing.

## Security Note

Treat the gateway bearer token as an operator credential. Do not expose it to untrusted clients. For local/dev it’s fine; for production consider using a trusted proxy or short-lived tokens.
