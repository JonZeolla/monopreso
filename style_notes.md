# Style Notes
- Ensure content is double-nested in &lt;section&gt; tags. The outer section handles the white background treatment, while the inner one gets text padding applied. This applies mainly to your intro content slides, which arent in an external file.
- add class="[color]" replacing [color] with red, green, or blue (default) to swap colors.
- iframes need to be in their own section file since the styles are applied to the top-level &lt;section&gt;
- To hide the background, add class="no-bg" to the outer section in your .j2 file.
- You may need to adjust some of your font headers to allow content to fit, or add style="margin-bottom:0" to the header tag.

## SANS Cloud Security Branding
Run with `--branding=sans-cloud-security --engine=revealjs` to apply the official SANS Cloud Security theme.

### Color classes
- `class="orange"` — SANS orange (#F5821F) for highlighted text
- `class="teal"` — Heading teal (#005880)
- `class="blue"` — Secondary blue (#0455A5)
- `class="highlight-sans-orange"` — Fragment highlight in SANS orange

### Special slide types
- **Title slide**: Add `data-background-color="#F5821F"` and `class="no-bg"` to the outer `<section>`.
- **Section divider**: Add `class="sans-section-divider no-bg"` to the outer `<section>`.
- **End slide**: Use `data-background-image` with `sans-cloud-bg-dark.jpg` (shared in modules/shared/img/).
- **Full-bleed images**: Add `class="no-bg"` to the outer `<section>`.

### Shared SANS Cloud Security images (modules/shared/img/)
- `sans-cloud-security-header.svg` — Header bar logo (auto-injected by branding)
- `sans-cloud-security-logo.png` — Round logo badge
- `sans-cloud-bg-dark.jpg` — Dark blue-teal cloud background
- `sans-cloud-security-curriculum-roadmap.jpg` — Curriculum roadmap for end slides
- `sans-cloud-security-flight-plan.png` — Flight plan graphic
