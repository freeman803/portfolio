# Andrew Freeman — Project Portfolio

A static HTML/CSS portfolio site for Andrew Freeman (mechanical engineering, Concordia
University; Technical Director of Concordia Formula Racing). It is a clean, hand-written
rebuild of the original Weebly site, free of any platform branding.

## Pages

- `index.html` — Home / about
- `pack-design.html` — High-voltage battery pack design
- `cooling-package-design.html` — Cooling package design
- `chassis.html` — Chassis design & fabrication
- `firmware.html` — Electrical & firmware integration
- `aws-deep-racer.html` — AWS DeepRacer reinforcement-learning project
- `wiring-harness.html` — HV battery pack wiring
- `regen-braking.html` — Regenerative braking simulation & firmware

## Structure

```
css/style.css   Single shared stylesheet (design tokens in :root)
js/nav.js       Mobile hamburger nav toggle (only JS on the site)
assets/images/  Project photos (placeholders for now)
assets/files/   Downloadable documents (placeholders for now)
```

## Deploy (GitHub Pages)

Live at **https://freeman803.github.io/portfolio/** — served from the `portfolio` project
repo (`main` branch, `/` root). The site is fully static, so no build step is required.