# Persaka Hackathon App — Product Website

A fully static, responsive product promotional website for the **Persaka Hackathon App**
(a Flutter + Firebase hackathon management app built by team **PaidRider**).

Built with **React + Vite + TypeScript**, styled with **Tailwind CSS**, and enhanced
with a few hand-picked **Aceternity UI** components. No backend required.

🔗 **Live (after deploy):** `https://zhengyu89.github.io/persaka_hackathon_app/`

---

## Tech stack

- [Vite](https://vitejs.dev/) + [React 18](https://react.dev/) + TypeScript
- [Tailwind CSS](https://tailwindcss.com/) v3
- [Motion](https://motion.dev/) (animations) + [lucide-react](https://lucide.dev/) (icons)
- Local **Aceternity UI** components: Spotlight, Bento Grid, Card Hover Effect, plus a
  floating/sticky navbar pattern

## Sections

Navigation · Hero · Problem & Solution · Features (Bento Grid) · App Screenshots ·
Benefits (Card Hover) · About · Team · Contact · Footer

## Project structure

```text
product_website/
├─ public/
│  ├─ favicon.png
│  └─ .nojekyll
├─ src/
│  ├─ assets/images/        # logo, product render, team photos (optimised copies)
│  ├─ components/
│  │  ├─ layout/            # Navbar, Footer
│  │  ├─ sections/          # Hero, Features, Screenshots, Team, Contact, ...
│  │  └─ ui/                # Aceternity components + reusable UI
│  ├─ data/
│  │  ├─ site.ts            # ALL editable content lives here
│  │  └─ types.ts
│  ├─ lib/utils.ts          # cn() + smooth scroll helper
│  ├─ App.tsx
│  ├─ main.tsx
│  └─ index.css
├─ index.html
├─ tailwind.config.js
└─ vite.config.ts
```

> **Editing content:** update `src/data/site.ts` — product info, nav items, features,
> benefits, screenshots, team members, and contact links are all defined there.

## Run locally

Requires Node.js 18+ (tested on Node 20/22).

```bash
cd product_website
npm install
npm run dev      # http://localhost:5173
```

## Build & preview

```bash
npm run build    # type-checks then outputs to dist/
npm run preview  # serves the production build locally
```

## Deploy to GitHub Pages

This repo includes a workflow at [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml)
that builds `product_website/` and publishes `dist/` to GitHub Pages.

1. Push to the `main` branch (the workflow triggers on changes under `product_website/`).
2. In the GitHub repo, go to **Settings → Pages → Build and deployment → Source** and
   select **GitHub Actions**.
3. The site deploys to `https://<username>.github.io/persaka_hackathon_app/`.

### Base path

`vite.config.ts` sets `base: "/persaka_hackathon_app/"` for production so all assets
resolve under the Pages sub-path. If you rename the repository, either update that value
or build with an override:

```bash
VITE_BASE="/<new-repo-name>/" npm run build
```

## Accessibility & performance notes

- Semantic landmarks, ordered headings, visible focus rings, keyboard-operable mobile menu.
- `prefers-reduced-motion` disables non-essential animation.
- Images are lazy-loaded below the fold, sized to avoid layout shift, and compressed.

## Placeholders to replace

- **App screenshots:** only the dashboard render (`Product_Image.png`) is real. The Teams,
  Submission Hub, Judging, and Leaderboard cards are placeholders — export real screens from
  the Flutter app and set their `image` field in `src/data/site.ts`.
- **Team social links:** `github` / `linkedin` fields in `src/data/site.ts` are optional and
  currently empty; add URLs to show the icons.
