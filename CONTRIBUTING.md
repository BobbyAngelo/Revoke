# Contributing to Revoke

Thanks for helping people reclaim their data privacy! Contributions of all sizes are welcome.

## Guiding principle

**Nothing should ever transmit user data off the device.** Revoke has no backend, no accounts, and no tracking, and it must stay that way. Pull requests that add servers, analytics, third-party trackers, or any network call that sends user information will not be merged.

## Ways to contribute

### 1. Add or correct a company

The company list lives in [`data/brokers.json`](data/brokers.json). Each entry looks like:

```json
{
  "id": "acxiom",
  "name": "Acxiom (LiveRamp)",
  "category": "data_broker",
  "privacy_email": "askprivacy@acxiom.com",
  "privacy_url": "https://example.com/optout",
  "method": "email",
  "risk_level": "critical",
  "notes": "Short, factual note about the company and how to reach them.",
  "pack": "critical"
}
```

Field reference:

- **id** — unique lowercase slug.
- **category** — one of: `data_broker`, `social_media`, `ad_network`, `retail`, `ai_company`, `surveillance`, `location_broker`, `health_data`, `finance`, `search`.
- **method** — `email`, `portal`, `web_form`, or `drp`.
- **risk_level** — `critical`, `high_priority`, `elevated`, `moderate`, `standard`, or `low`.
- **privacy_email** — the company's verified privacy contact (omit or leave blank if portal-only).
- **privacy_url** — the official opt-out/portal URL.

Please cite a source for new privacy contacts in your PR description. **Verify the email or portal is current** — outdated contacts are worse than none.

After editing the JSON, regenerate the bundled JS:

```bash
{ echo "// Auto-generated from data/brokers.json. Do not edit by hand."; \
  printf 'window.BROKERS = '; cat data/brokers.json; echo ';'; } > js/brokers.js
```

### 2. Add a state privacy law

When a new US state law takes effect, add it to `window.PRIVACY_LAWS` in [`js/data.js`](js/data.js) with the official statute citation and response deadline, and add the AG complaint contact to `window.AG_EMAILS`.

### 3. Improve the request templates

The legal request and AG complaint wording lives in [`js/templates.js`](js/templates.js). Keep changes accurate and neutral. If a change affects legal substance, note your reasoning and any source.

## Local development

No build step. Serve the folder with any static server:

```bash
python3 -m http.server 8000   # then open http://localhost:8000
```

## Pull request checklist

- [ ] No new servers, analytics, or trackers; no user data leaves the device.
- [ ] If you edited `data/brokers.json`, you regenerated `js/brokers.js`.
- [ ] New privacy contacts / statutes include a source.
- [ ] The app still loads and the Browse, Sent, Learn, and Settings tabs work.

## Disclaimer

Revoke is not a law firm and does not provide legal advice. Contributions are made under the project's [MIT License](LICENSE).
