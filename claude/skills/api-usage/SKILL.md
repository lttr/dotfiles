---
name: api-usage
disable-model-invocation: true
description: Check Anthropic API spend and token usage from the org admin API with curl + jq. User-invoked only (/api-usage).
---

# API Usage

Quick look at Anthropic **API** spend and token usage for an organization.

## Prerequisites

- `jq` — JSON parsing
- `op` — 1Password CLI, to load the admin key (or supply the key another way)

## Key

Needs an **admin** key (`sk-ant-admin...`). Normal API keys and user-OAuth
tokens get `403 Authentication method not allowed`, and `ant` has no org
usage/cost commands, so this is plain `curl`. Load the key without printing it:

```bash
export AK=$(op read "op://<vault>/<item>/<field>" | tr -d '[:space:]')
H=(-H "x-api-key: $AK" -H "anthropic-version: 2023-06-01")

# Range as RFC3339 UTC. Defaults below = current year to date; override as needed.
START="$(date -u +%Y-01-01T00:00:00Z)"
END="$(date -u -d tomorrow +%Y-%m-%dT00:00:00Z)"
```

## Spend (USD)

```bash
# Total billed for the range (follow .next_page if .has_more is true)
curl -s "https://api.anthropic.com/v1/organizations/cost_report?starting_at=$START&ending_at=$END" "${H[@]}" \
  | jq '[.data[].results[].amount|tonumber]|add'

# Per model + token-type, line by line
curl -s "https://api.anthropic.com/v1/organizations/cost_report?starting_at=$START&ending_at=$END&group_by[]=description" "${H[@]}" \
  | jq -r '.data[].results[]|select(.amount!="0")|"\(.amount)\t\(.model)\t\(.token_type)"'
```

`cost_report` group_by only accepts `description` and `workspace_id`.

## Token usage

```bash
# Tokens by model (bucket_width: 1d | 1h; default limit 7 buckets, so paginate)
curl -s "https://api.anthropic.com/v1/organizations/usage_report/messages?starting_at=$START&ending_at=$END&bucket_width=1d&group_by[]=model" "${H[@]}" \
  | jq -r '.data[].results[]|"\(.model)\tin=\(.uncached_input_tokens)\tout=\(.output_tokens)\tcache_rd=\(.cache_read_input_tokens)"'
```

Group by `api_key_id` to attribute usage; a **high cache-read ratio is the Claude
Code signature**. Interactive Claude Code on a Pro/Max subscription runs over
OAuth, not an API key, so it does **not** appear here and is not API credit spend.

## Sanity check: the cost_report vs usage_report glitch

These two endpoints can disagree by a constant multiplier for some orgs — same
days, models, and token types, only the magnitude differs. Cross-check
`cost_report` dollars against the token counts priced at standard list rates; if
they diverge by a large factor, trust the **token-derived** figure and confirm
against the Console invoice.

## Credits remaining

Not exposed by the admin API. Console only:
<https://console.anthropic.com/settings/billing>
