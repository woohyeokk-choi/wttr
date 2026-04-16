# wttr landing page

Static landing at [wttr.fyi](https://wttr.fyi).

## Local preview

```bash
cd landing
python3 -m http.server 4000
# open http://localhost:4000
```

Pure HTML/CSS — no build step, no dependencies.

## Structure

```
landing/
├── index.html     # Single-page landing
├── style.css      # Design tokens mirror docs/design.md
├── favicon.svg    # Tab icon
├── CNAME          # wttr.fyi — read by GitHub Pages
└── .nojekyll      # Skip Jekyll processing
```

## Deploy (GitHub Pages)

Two options:

### Option A — `gh-pages` branch via Actions (recommended)
Add `.github/workflows/pages.yml` that publishes this folder to a `gh-pages`
branch on push to `main`. Repo settings → Pages → Source: `gh-pages` branch.

### Option B — `/landing` folder as site root
Requires GitHub Pages to support arbitrary folder sources (currently only
`/` or `/docs`). If limited, move contents to `/docs` or use Option A.

## Custom domain

`CNAME` already contains `wttr.fyi`. After first deploy:

1. Repo → Settings → Pages → confirm the custom domain is picked up.
2. DNS at the registrar:
   - Apex `wttr.fyi` → four GitHub Pages A records
     (`185.199.108.153`, `.109.153`, `.110.153`, `.111.153`)
   - Optional `www.wttr.fyi` CNAME → `<user>.github.io`
3. Enable **Enforce HTTPS** once the Let's Encrypt cert issues (~15 min).

## Still TODO

- [ ] Real waitlist provider (Buttondown / ConvertKit / Formspree) — swap the
      `onsubmit` handler in `index.html`.
- [ ] `og-image.png` (1200×630) for link previews.
- [ ] `apple-touch-icon.png` (180×180).
- [ ] `/privacy` and `/terms` pages.
- [ ] Replace CSS phone mockup with real screenshots once the app has UI.
