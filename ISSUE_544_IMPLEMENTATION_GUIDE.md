# Issue #544 Implementation Guide — pkgdown Branding to “engager”

## Overview
Update pkgdown branding from “zoomstudentengagement” to “engager”, rebuild the site, and deploy to GitHub Pages. Keep scope limited to branding/content. Deployment mechanics are in #219.

## Prerequisites
- R installed; pkgdown available: `install.packages('pkgdown')`
- GitHub Pages workflow configured (existing in repo)
- Branch permissions in place

## Step-by-Step Plan

1. Create feature branch
```
git checkout -b docs/issue-544-pkgdown-branding
```

2. Update `_pkgdown.yml`
- Set `title: engager`
- Ensure navbar brand uses “engager”
- Verify any footer or home description referencing the package name uses “engager”

3. Audit and update headings in vignettes and README
- Only change prose/headers saying the old name; do not modify code blocks/package references
- Files to check:
  - `vignettes/*.Rmd` active vignettes
  - `README.Rmd`/`README.md`
  - Any `docs/` source content if applicable (site is generated; prefer source)

4. Build locally and validate
```
R -q -e "pkgdown::clean_site(); pkgdown::build_site()"
```
- Manually open `docs/index.html` and vignettes index; confirm “engager” branding throughout

5. Commit changes
```
git add _pkgdown.yml vignettes README.Rmd README.md
git commit -m "docs(pkgdown): update branding to 'engager' and rebuild site (fix #544)"
```

6. Push branch and open PR
```
git push -u origin docs/issue-544-pkgdown-branding
```
- Open PR titled: “docs(pkgdown): update branding to ‘engager’ and rebuild Pages (fix #544)”
- Link to #219 for deploy workflow context

7. CI & Deploy
- Ensure pkgdown build job runs; Pages deploy job completes
- If Pages fails due to cache, retry with cache cleared or adjust workflow (tracked in #219)

8. Post-merge verification
- Visit `https://revgizmo.github.io/engager/`
- Verify title, navbar, vignette index headings, and article pages show “engager”
- Capture screenshots and attach to #544 before closing

## Acceptance Criteria
- Branding updated across site (home, navbar, vignettes)
- CI pkgdown build succeeds; Pages deployed
- Live site reflects changes within minutes after merge

## Notes
- Keep this PR free of unrelated content updates
- Any Pages workflow changes belong in #219


