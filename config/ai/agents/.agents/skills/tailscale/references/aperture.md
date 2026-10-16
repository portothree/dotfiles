# Aperture by Tailscale

Aperture is a centralized AI gateway that sits between LLM clients (coding agents, apps, scripts) and upstream providers (OpenAI, Anthropic, Google, Bedrock, Vertex, OpenRouter, and others.). It gives an organization one control point for API keys, access control, spending limits, telemetry, and audit.

> **Aperture is in beta and its docs change frequently.** Treat the snippets below as orientation only. For any concrete answer — provider settings, environment variables, configuration keys, supported features, model names — **WebFetch the matching docs page** from the table below before responding. Do not rely on memory for specifics.

## Mental model (stable)

Four mechanisms, useful for reasoning about behavior even when specifics change:

1. **Identity** — every connection is identified by its Tailscale identity (user email or device tag). No separate API keys for end-users.
2. **Routing** — clients name a model (`claude-sonnet-4-6`); Aperture looks up which provider serves it, injects upstream credentials, and forwards.
3. **Telemetry** — full request/response, token counts, duration, tool use, and session captured asynchronously after the response.
4. **Session tracking** — related requests grouped into sessions; client session IDs (Claude Code, Codex) auto-detected.

Aperture is **deny-by-default**: without a matching grant, nothing is allowed.

## Canonical shapes (verify exact fields against live docs)

These configuration skeletons drift in field names and values but not in shape. Use them as a sketch; **WebFetch the relevant page below for the current keys** before committing configuration changes.

**A grant.** Grants live in *either* the Aperture configuration *or* the tailnet policy file — the two forms use the same `tailscale.com/cap/aperture` capability but are **not interchangeable as written**. The only difference is the `dst` field: Aperture configuration grants **omit** `dst` (the destination is implicitly the Aperture instance); tailnet policy file grants **require** `dst` targeting the Aperture device (for example `["tag:aperture"]`).

Aperture configuration form (no `dst`):

```json
{
  "grants": [{
    "src": ["group:engineering"],
    "app": {
      "tailscale.com/cap/aperture": [
        { "role": "user" },
        { "models": "anthropic/**" }
      ]
    }
  }]
}
```

Inside the capability array, `role` and `models` are **separate objects**, and `models` is a **single glob string** (not an array — for multiple patterns, add more `{"models": "..."}` entries). `role` is required: without it, requests get HTTP 403 even when a `models` pattern matches. A `connectors` entry (array of FQN globs) grants access to MCP tools and HTTP connector proxies. The capability string is `tailscale.com/cap/aperture`; roles are `user` and `admin`; model patterns use glob syntax (`**`, `anthropic/**`, `*/claude-sonnet*`). Matching `group:` sources requires visible groups enabled for the Aperture device.

**A spending quota** (token-bucket model; capacity is the cap, rate refills it):

```json
{
  "quotas": {
    "daily:<user>": {
      "capacity": "$10.00",
      "rate": "$5.00/day",
      "on_exceed": "reject"
    }
  }
}
```

`<user>` expands to the Tailscale login (per-person buckets); `<node>` expands to node ID (per-device). `on_exceed: "reject"` returns HTTP 429.

**A provider** (Anthropic shown; other providers follow the same shape with different `authorization` and `compatibility` flags — fetch the provider page for specifics):

```json
{
  "providers": {
    "anthropic": {
      "baseurl": "https://api.anthropic.com",
      "apikey": "YOUR_ANTHROPIC_API_KEY",
      "models": ["claude-sonnet-4-6", "claude-opus-4-7", "claude-haiku-4-5"],
      "authorization": "x-api-key",
      "compatibility": {"anthropic_messages": true}
    }
  }
}
```

## Quickstart shape (verify against live docs)

```bash
# Create an instance
open https://aperture.tailscale.com

# Reach the dashboard from a tailnet device
open http://ai/ui/

# Smoke-test (Anthropic format)
curl -s http://ai/v1/messages \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-haiku-4-5","max_tokens":25,"messages":[{"role":"user","content":"hello"}]}'
```

The hostname `ai` resolves via MagicDNS — if it doesn't, MagicDNS is off. Use `http://`, not `https://`.

## Where to find current information — fetch these

Always WebFetch the page that matches the user's question. The Aperture index is the fallback when a topic isn't listed here.

| User is asking about… | Fetch |
|---|---|
| What Aperture is, why it exists | https://tailscale.com/docs/aperture/what-is-aperture |
| Architecture, request flow | https://tailscale.com/docs/aperture/how-aperture-works |
| First-time setup | https://tailscale.com/docs/aperture/get-started |
| Full configuration reference, JSON schema | https://tailscale.com/docs/aperture/configuration |
| Configuring providers (any) | https://tailscale.com/docs/aperture/set-up-providers |
| Which providers/models are supported | https://tailscale.com/docs/aperture/provider-compatibility |
| Specific provider — Anthropic | https://tailscale.com/docs/aperture/how-to/use-anthropic |
| Specific provider — OpenAI | https://tailscale.com/docs/aperture/how-to/use-openai |
| Specific provider — Bedrock | https://tailscale.com/docs/aperture/how-to/use-amazon-bedrock |
| Specific provider — Vertex AI | https://tailscale.com/docs/aperture/how-to/use-vertex-ai |
| Specific provider — Vertex AI Express | https://tailscale.com/docs/aperture/how-to/use-vertex-ai-express |
| Specific provider — Gemini | https://tailscale.com/docs/aperture/how-to/use-google-gemini |
| Specific provider — Microsoft Foundry (Azure OpenAI + Anthropic) | https://tailscale.com/docs/aperture/how-to/use-microsoft-foundry |
| Specific provider — OpenRouter | https://tailscale.com/docs/aperture/how-to/use-openrouter |
| Specific provider — Vercel AI Gateway | https://tailscale.com/docs/aperture/how-to/use-vercel |
| Specific provider — OpenAI-compatible | https://tailscale.com/docs/aperture/how-to/use-openai-compatible-tools |
| Specific provider — self-hosted (llama.cpp and others) | https://tailscale.com/docs/aperture/how-to/use-self-hosted |
| Coding agents — overview | https://tailscale.com/docs/aperture/use-your-tools |
| Coding agents — Claude Code | https://tailscale.com/docs/aperture/how-to/use-claude-code |
| Coding agents — Claude Code GitHub Action | https://tailscale.com/docs/aperture/how-to/use-claude-code-action |
| Coding agents — Codex | https://tailscale.com/docs/aperture/how-to/use-codex |
| Coding agents — OpenCode | https://tailscale.com/docs/aperture/how-to/use-opencode |
| Aperture CLI (discover/configure/launch agents, bridges, additional agents like Gemini CLI, GitHub Copilot, Claude Cowork) | https://tailscale.com/docs/aperture/cli |
| Connecting devices not on the tailnet (ts-unplug) | https://tailscale.com/docs/aperture/connect-outside-tailnet |
| Access control / grants — concepts | https://tailscale.com/docs/aperture/control-access |
| Aperture configuration grants vs. tailnet policy file grants (the `dst` difference) | https://tailscale.com/docs/aperture/reference/aperture-vs-tailnet-grants |
| Granting model access (recipe) | https://tailscale.com/docs/aperture/how-to/grant-model-access |
| Granting admin role | https://tailscale.com/docs/aperture/how-to/set-up-admin-access |
| Using `group:` in grants (requires visible groups) | https://tailscale.com/docs/aperture/visible-groups |
| Spending limits / quotas — concepts | https://tailscale.com/docs/aperture/manage-spending |
| Per-user spending limits | https://tailscale.com/docs/aperture/how-to/set-per-user-spending-limits |
| Team-wide budget pool | https://tailscale.com/docs/aperture/how-to/set-team-budget |
| Checking & refilling budgets | https://tailscale.com/docs/aperture/how-to/check-and-refill-budgets |
| Guardrails (pre-request hooks) — concepts | https://tailscale.com/docs/aperture/guardrails |
| Setting up guardrails | https://tailscale.com/docs/aperture/how-to/set-up-guardrails |
| Webhooks / integrations — overview | https://tailscale.com/docs/aperture/integrate |
| Building a custom webhook | https://tailscale.com/docs/aperture/how-to/build-custom-webhook |
| Integration — Oso | https://tailscale.com/docs/aperture/integrate/oso |
| Integration — Cerbos | https://tailscale.com/docs/aperture/integrate/cerbos |
| Integration — Cribl | https://tailscale.com/docs/aperture/integrate/cribl |
| Integration — Highflame | https://tailscale.com/docs/aperture/integrate/highflame |
| Observability, exports | https://tailscale.com/docs/aperture/observe-and-export |
| S3 export | https://tailscale.com/docs/aperture/how-to/export-usage-data-to-s3 |
| MCP server proxying | https://tailscale.com/docs/aperture/mcp-server |
| Granting MCP tool access | https://tailscale.com/docs/aperture/how-to/grant-mcp-tool-access |
| Connectors (outbound MCP and HTTP API integrations) overview | https://tailscale.com/docs/aperture/connectors |
| Connectors: get started | https://tailscale.com/docs/aperture/connectors/get-started |
| Connectors: full reference (auth types, protocols, statuses) | https://tailscale.com/docs/aperture/connectors/reference |
| Connectors: using a connector from a client | https://tailscale.com/docs/aperture/connectors/use-a-connector |
| Connectors: authenticated MCP connector | https://tailscale.com/docs/aperture/connectors/set-up-authenticated-mcp-connector |
| Connectors: HTTP API connector | https://tailscale.com/docs/aperture/how-to/set-up-http-api-connector |
| Connectors: per-user OAuth 2.0 connector | https://tailscale.com/docs/aperture/how-to/set-up-per-user-oauth2-connector |
| Browser chat UI (`chat_models` configuration, `enable_chat_ui` grant) | https://tailscale.com/docs/aperture/how-to/set-up-chat-ui |
| Chat sandbox — overview (isolated code execution) | https://tailscale.com/docs/aperture/chat-sandbox |
| Chat sandbox — enable | https://tailscale.com/docs/aperture/how-to/enable-sandbox |
| Chat sandbox — manage | https://tailscale.com/docs/aperture/how-to/manage-sandbox |
| Dashboard UI | https://tailscale.com/docs/aperture/reference/dashboard |
| Admin dashboard | https://tailscale.com/docs/aperture/reference/dashboard-admin |
| Reference index | https://tailscale.com/docs/aperture/reference |
| How-to index | https://tailscale.com/docs/aperture/how-to |
| Troubleshooting | https://tailscale.com/docs/aperture/troubleshooting |
| **Anything else / topic not listed** | https://tailscale.com/docs/aperture |

## Worked examples

| If the user wants to… | Fetch |
|---|---|
| Centralize their team's LLM API keys and track cost and usage per person | https://tailscale.com/docs/use-cases/ai-infrastructure-access/centralize-llm-access-and-spending |
| Route AI code reviews through a governed gateway | https://tailscale.com/docs/solutions/route-ai-code-reviews-through-aperture |

## Answering pattern

1. Read the user's question and match it to a row above (or to the Aperture index).
2. WebFetch that page.
3. Answer from the fetched content. Quote configuration keys, environment variables, model names, and prices verbatim from the page — these are exactly the values that drift.
4. If the fetched page references a related topic the user might need, mention it and fetch on a follow-up.

If a configuration example, provider name, environment variable, or pricing detail is not present in the page you fetched, say so rather than inventing it from memory.
