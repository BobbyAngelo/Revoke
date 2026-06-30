<div align="center">
  <img src="assets/icon.png" alt="Revoke" width="88" height="88" style="border-radius:20px">
  <h1>Revoke</h1>
  <p><strong>Reclaim your data privacy.</strong> One click to send legally-compliant data deletion, opt-out, and access requests to 178+ companies based on your US state privacy law.</p>
</div>

---

Companies profit from your personal data every day. Data brokers, ad networks, AI companies, and Big Tech collect your name, address, location, browsing habits, purchase history, and more. Most US state privacy laws give you the right to make them stop. **Revoke makes exercising that right take seconds.**

Pick a company, choose a request type, and Revoke generates an email that cites the exact statute that applies to you and opens it in your mail app. It saves a receipt, tracks the legal response deadline, and, if a company ignores you, drafts a complaint to your state Attorney General.

This is the **web version** of Revoke, rebuilt as a static, no-backend site. The original iOS (SwiftUI) app is preserved in [`legacy-ios/`](legacy-ios/).

## Privacy by design

Revoke collects **nothing**. There are no accounts, no servers, no analytics, and no tracking. Your name, email, and request history live only in your browser's `localStorage` and never leave your device. It would be hypocritical to build a privacy tool any other way.

## Features

- **178+ companies** across 10 categories: data brokers, AI, surveillance, social media, ad networks, health, finance, retail, search, and location
- **Legally-worded requests** citing your state's specific privacy statute
- **Three request types**: Delete, Opt Out of Sale, or Access ("what do you have?")
- **Deadline tracking**: every sent request is logged with its statutory response deadline
- **Attorney General complaint generator** for companies that miss the deadline or refuse
- **Portal detection** for companies that require a web form instead of email
- **Full-text search** and category filtering
- **Copy-to-clipboard** fallback when no mail client is configured

## Supported state privacy laws

California (CCPA/CPRA), Colorado (CPA), Connecticut (CTDPA), Virginia (VCDPA), Texas (TDPSA), Oregon (OCPA), New Jersey (NJDPA), Delaware (DPDPA), Maryland (MODPA), Indiana (INDPA), Kentucky (KCDPA), Montana (MTCDPA), New Hampshire (NHDPA), Iowa (ICDPA), Tennessee (TIPA), Minnesota (MCDPA), and Nebraska (NEDPA), plus a nationwide CCPA fallback for every other state.

## Run it locally

It's a static site with no build step. Any static server works:

```bash
# Python
python3 -m http.server 8000

# or Node
npx serve .
```

Then open <http://localhost:8000>. (Opening `index.html` directly via `file://` also works, since the broker data is bundled as JavaScript.)

## Deploy to GitHub Pages

1. Push this repository to GitHub.
2. Go to **Settings → Pages**.
3. Under **Build and deployment**, set **Source** to *Deploy from a branch*, branch **`main`**, folder **`/ (root)`**.
4. Save. Your site goes live at `https://<your-username>.github.io/Revoke/`.

## Project structure

```
index.html            # App shell
css/styles.css        # Styles
js/brokers.js         # 178+ companies (generated from data/brokers.json)
js/data.js            # State privacy laws + category metadata
js/templates.js       # Email + AG complaint templates
js/store.js           # localStorage persistence + status logic
js/app.js             # UI controller (Browse / Sent / Learn / Settings)
data/brokers.json     # Source company dataset
assets/               # App icon
legacy-ios/           # Original SwiftUI iOS app (archived)
```

### Updating the company list

Edit `data/brokers.json`, then regenerate the bundled JS:

```bash
{ echo "// Auto-generated from data/brokers.json. Do not edit by hand."; \
  printf 'window.BROKERS = '; cat data/brokers.json; echo ';'; } > js/brokers.js
```

## Contributing

Contributions are welcome, especially:

- Adding companies or correcting privacy contact details in `data/brokers.json`
- Adding newly-effective state privacy laws in `js/data.js`
- Improving the legal request templates in `js/templates.js`

Please keep the no-backend, no-tracking principle intact: nothing should ever transmit user data off the device. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community expectations.

## Disclaimer

Revoke is **not a law firm and does not provide legal advice.** It helps you exercise privacy rights you already have under existing law. Statutes and company contact details change; verify specifics for your situation. See the [Privacy Policy](privacy.html) and [Terms of Use](terms.html).

## License

[MIT](LICENSE) © 2026 BobbyAngelo
