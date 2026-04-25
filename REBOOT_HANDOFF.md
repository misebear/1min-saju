# Reboot Handoff

Date: 2026-04-24

## Saved state

- SEO expansion work is committed and pushed.
- Latest commit for this work: `328dd23`
- Commit message: `Expand public SEO landings and acquisition tracking`

## What was implemented

- Public landing pages strengthened for:
  - `/`
  - `/saju/new`
  - `/compatibility/new`
  - `/dreams/new`
  - `/tarot/new`
  - `/tojeong/new`
  - `/career/new`
  - `/fortunes/daily`
  - `/fortunes/yearly`
  - `/chat`
- Long-tail SEO pages strengthened for:
  - `/zodiac/:sign`
  - `/tti/:animal`
- Added grouped internal-link hub:
  - `app/views/shared/_public_discovery_panel.html.erb`
- Added reusable SEO CTA partial:
  - `app/views/shared/_seo_cta_card.html.erb`
- Added GA click tracking attributes and delegated JS tracking for:
  - `landing_cta_click`
  - `related_tool_click`
  - `start_saju_from_landing`
- Updated sitemap to include public landings and fixed zodiac sign entries to full names.
- Updated `public/robots.txt` to stop blocking:
  - `/fortunes/daily`
  - `/fortunes/yearly`
  - `/chat`

## Verified locally

- Local Rails server on port 3001 returned `200` for:
  - `/`
  - `/saju/new`
  - `/compatibility/new`
  - `/dreams/new`
  - `/tarot/new`
  - `/tojeong/new`
  - `/career/new`
  - `/fortunes/daily`
  - `/fortunes/yearly`
  - `/chat`
  - `/zodiac/양자리`
  - `/tti/쥐`
  - `/robots.txt`
  - `/sitemap.xml`
- Local HTML checks passed for:
  - landing H1/title text
  - FAQ sections
  - analytics data attributes
  - sitemap entries
  - robots unblocking

## Production recheck completed

Rechecked on 2026-04-25 KST after reboot.

- Production endpoints returned `200` for:
  1. `https://www.1minsaju.com/robots.txt`
  2. `https://www.1minsaju.com/sitemap.xml`
  3. `https://www.1minsaju.com/fortunes/daily`
  4. `https://www.1minsaju.com/chat`
  5. `https://www.1minsaju.com/zodiac/%EC%96%91%EC%9E%90%EB%A6%AC`
- `robots.txt` does not block public `/fortunes/daily`, `/fortunes/yearly`, or `/chat`.
- `robots.txt` still blocks `/chat/message`, which is correct because it is not a public SEO landing.
- `sitemap.xml` is live and contains the new public landing entries and full zodiac URLs.
- Conclusion: the SEO deploy is live enough for the interrupted verification goal.

## Important note

- There are unrelated local Supabase migration changes still present and intentionally not included in the SEO commit.
