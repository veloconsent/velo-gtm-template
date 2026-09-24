# Velo CMP — GTM Community Template

The official Google Tag Manager tag template for [Velo](https://veloconsent.com).
One tag installs the whole CMP through GTM — no Custom HTML, no code changes on
the page:

- Sets a **region-scoped Google Consent Mode v2 default** synchronously, before
  any measurement tag can fire: everything non-essential denied in the EEA, UK,
  Switzerland and Brazil; Velo's opt-out model (granted until the visitor says
  otherwise, with Global Privacy Control honoured) everywhere else.
- Loads Velo's SDK (`velo.js`), which renders the consent banner, resolves
  regional policy, sends `gtag('consent', 'update', …)` on every decision, and
  mirrors the decision to Microsoft UET and Meta where present.
- Pushes a **`velo_consent_update`** event (with a `velo_categories` object) to
  the data layer on every path consent becomes effective — including a stored
  decision re-applied for a returning visitor — so you can fire consent-gated
  tags from a plain Custom Event trigger.

## Installing

1. In Tag Manager: **Templates → Tag Templates → Search Gallery** → search
   "Velo" → **Add to workspace**. (Until the gallery listing is live, or for a
   private install: download `template.tpl` from this repository, then
   **Templates → Tag Templates → New → ⋮ → Import**.)
2. Create a tag from the template. Fields:
   - **Velo site ID** — from your Velo dashboard; leave `default` for a
     single-site account.
   - **Banner theme** — light or dark card.
   - **Banner language** — the visitor's browser language (default), or **Page
     language** for a multilingual site: the banner follows the page's
     `<html lang>`, so `/es` gets a Spanish banner whatever the browser says.
   - **Velo API endpoint** — keep the default `https://app.veloconsent.com`.
     It is where each visitor's choice is recorded (your dashboard's consent
     log) and where the banner settings you save in Velo are loaded from. An
     empty field falls back to the same address.
   - **Advanced** — banner text overrides, **Cookie policy URL** (adds a
     "Cookie policy" link to the end of the first-layer message — a path like
     `/cookies` or a full `https://` URL), `ads_data_redaction`,
     `url_passthrough`.
3. Fire the tag on the **Consent Initialization - All Pages** trigger. This is
   the one Google provides specifically for consent defaults — it runs before
   every other trigger.
4. Optional: to fire your own tags only after a decision, add a **Custom
   Event** trigger for `velo_consent_update` and a Data Layer Variable for
   `velo_categories` (an object of booleans: `analytics`, `ads`, `functional`,
   `personalization`). For Google tags you usually don't need this — Consent
   Mode's built-in consent checks handle them.
5. Publish the container version.

Full install guide with screenshots: https://veloconsent.com/google-tag-manager

## How configuration travels

GTM's sandboxed `injectScript(url)` API cannot set `data-*` attributes on the
script element it creates (and `document.currentScript` is null for dynamic
injection). So this template passes configuration as query parameters on
`velo.js`'s own `src` — `…/v1/velo.js?site=acme&theme=dark` — and the SDK reads
its own src query string as a first-class config channel (`srcQueryConfig` in
`banner-sdk/src/config.js`). `data-*` attributes still win over query
parameters when both are present, so inline installs behave exactly as before.

## Keeping the region list honest

The template's sandboxed JS carries a hand-kept copy of the SDK's
`OPT_IN_REGIONS` list (EU 27 + EEA non-EU + UK + Switzerland + Brazil), because GTM's
sandbox has no module loader to share a real import across the boundary. If
the SDK's list ever changes, the template's copy must change in the same
release — the source of truth lives in the Velo codebase at
https://github.com/leonaves/velo (`packages/banner-sdk/src/payload.js`).

## History

This template replaces the earlier "Velo – Consent Mode Bridge" template from
this same repository. The bridge (and the Custom HTML snippet it required) is
obsolete: the SDK now pushes `velo_consent_update` to the data layer itself
and has always sent its own `gtag` consent updates, so there is nothing left
to bridge.

## Support

Open an issue on this repository, or see https://veloconsent.com/help.
