# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

The GitHub Pages documentation site for ESP (Evented State Processor), published at https://esp.github.io/. It is a Jekyll site that uses the Minimal Mistakes theme. It holds documentation only: the library source lives in `esp/esp-js`. There is no application code, test suite or linter here.

## Commands

- **Build and serve locally:** `./dev-build.sh`. This needs Docker. It runs the `jekyll/jekyll` container (Jekyll 4.2.2), mounts `vendor/bundle` as the gem cache, and serves on http://127.0.0.1:4000. Changes to `_config.yml` take effect only after a server restart.
- **Update Ruby dependencies:** delete `Gemfile.lock`, then run `bundle install --path vendor/bundle`. `.bundle/config` pins `BUNDLE_PATH` to `vendor/bundle`, which is gitignored.

## Structure and how pages are wired

- `index.md` is the home page (`permalink: /`, `layout: splash`).
- `_docs/` holds every published page. `_config.yml` adds it to `include`. The numeric prefixes on folders and files only set the order on disk. **The URL comes from each file's `permalink` front matter**, not from its path (for example `_docs/01-concepts/01-esp-js/02-event-router.md` → `/concepts/esp-js/event-router/`).
- `_config.yml` `defaults` assign a layout by path. Pages under `_docs/01-concepts` get `layout: single` and the `concepts` sidebar. Installation, examples, source and roadmap get `layout: splash`.
- `_data/navigation.yml` defines the top nav (`main`) and the concepts sidebar (`concepts`). **A new or renamed concept page must also be added here** with a URL that matches its `permalink`, or it will not appear in the sidebar.
- The concepts follow the ESP packages: `00-overview`, `01-esp-js` (router, state-change workflow, OO modeling), `02-esp-js-polimer`, `03-esp-js-react`, `04-esp-js-di` and `05-esp-js-ui`.
- `archive/` holds older guides and the package READMEs that the new docs replace. It is not excluded in `_config.yml`, so Jekyll still processes it, but none of it is linked from the nav.
- `images/` holds the diagrams. Pages usually link to them with relative paths (`![](../../../images/foo.png){: .align-center}`).
- `assets/css/main.scss` overrides the theme. Any Sass variables must be set before the theme imports.

## Content conventions

- **Callouts:** capture the content first, then include a callout:
  ```liquid
  {% capture info_1 %}Markdown content{% endcapture %}
  {% include callout-info.html content=info_1 title="Optional title" %}
  ```
  The variants are `callout-info`, `callout-success` and `callout-warning`. Without a `title` the heading defaults to "Note".
- `{% include draftdocs.html %}` adds the "Draft documentation" banner. Many esp-js-polimer, esp-js-react and esp-js-ui pages are still stubs that show this banner.
- Live code samples are CodePen embeds (`<p class="codepen" data-user="KeithWoods" data-slug-hash="...">`). YouTube videos use the theme's `{% include video id="..." provider="youtube" %}`.
