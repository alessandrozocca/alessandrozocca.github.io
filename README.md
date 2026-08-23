# Alessandro Zocca's academic website

Source for [alessandrozocca.github.io](https://alessandrozocca.github.io/), an academic website built with [Jekyll](https://jekyllrb.com/) and the [al-folio](https://alshedivat.github.io/al-folio/) theme.

## Local development

Use the Ruby version declared in `.ruby-version` and Bundler. The production workflow currently builds with Ruby 3.2.2.

```sh
bundle install
bundle exec jekyll serve
```

The local preview is then available at `http://127.0.0.1:4000/`. Run the production build before committing:

```sh
JEKYLL_ENV=production bundle exec jekyll build
npx purgecss -c purgecss.config.js
bundle exec ruby scripts/check_site.rb _site
```

Do not edit `_site/`; it is generated output.

## Where to update the site

- `_pages/about.md`: homepage biography and profile details.
- `_bibliography/papers.bib`: publication metadata and publication links.
- `_news/`: dated research announcements.
- `_data/cv.yml`: the web CV; `assets/pdf/CVzocca.pdf` is the downloadable full CV.
- `_data/repositories.yml`: software and reproducibility resources.
- `_config.yml`: site-wide metadata, navigation, integrations, and feature flags.
- `_sass/` and `assets/js/`: visual system and interactions.

## Deployment

Pushing a site-related change to `master` or `main` starts `.github/workflows/deploy.yml`. It builds the production Jekyll site, purges unused CSS, and publishes `_site/` to the `gh-pages` branch. GitHub Pages then serves that branch. Do not commit generated `_site/` files or manually edit `gh-pages`.

The deployment workflow is intentionally the sole publisher. Quality-assurance workflows should report problems without publishing or rewriting the production branch.

## Review checklist

Before publishing a substantive update:

- Build the site from a clean checkout and review every public route.
- Check names, dates, job titles, grant and manuscript statuses, and DOI metadata.
- Verify new internal and external links; use HTTPS and descriptive link text.
- Confirm that each page has one `h1`, a useful description, and logical heading order.
- Add meaningful alt text to informative images and an empty alt attribute to decorative images.
- Check keyboard focus, disclosure controls, and forms without a mouse.
- Inspect 320px, 375px, 768px, 1024px, and wide-desktop layouts for overflow.
- Confirm that the accent and text retain WCAG AA contrast and that links are not identified by color alone.
- Update both the web CV and PDF CV when the same fact appears in both.
