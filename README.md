# Velo – Consent Mode Bridge (GTM Community Template)

A Google Tag Manager tag template that forwards [Velo](https://veloconsent.com)'s
consent decision into Google Consent Mode v2, for sites that manage their tags
through GTM instead of editing Velo's direct `<script>` snippet into their pages.

## What it is

`template.tpl` is a real, importable GTM custom tag template — the sandboxed
JS, template parameters, and permissions are all filled in and reviewable, and
its consent mapping is a deliberate, commented copy of Velo's SDK
(`gtagConsentFromCategories`, see the NOTES section inside `template.tpl` for
why it can't be a real shared import — GTM's sandbox has no module loader).

## Why a bridge snippet is needed

Velo's SDK dispatches its consent decision as a native browser event
(`window.dispatchEvent(new CustomEvent('velo:consent', { detail }))`) and
exposes `window.Velo.consentState()`. GTM's own trigger system — Custom Event
triggers, the ones this tag is meant to fire from — watches the **data layer**
(`window.dataLayer`), not arbitrary native `window` events. So a few lines on
the page forward Velo's event onto the data layer, and this tag reads it back
from there. Every other CMP-to-GTM integration on the gallery (Cookiebot,
OneTrust, Usercentrics, ...) has the same shape: a small bridge, then a
template that reads the data layer.

## Installing

1. Add this bridge snippet as an early Custom HTML tag, firing on all pages,
   before any tag that should be consent-gated:

   ```html
   <script>
     window.addEventListener('velo:consent', function (e) {
       window.dataLayer = window.dataLayer || [];
       window.dataLayer.push({
         event: 'velo_consent_update',
         velo_categories: e.detail.categories,
       });
     });
   </script>
   ```

2. In Tag Manager, open the container → **Templates** → **Tag Templates** →
   **New** → the "⋮" menu in the top right → **Import** (or, once this
   template is listed in the gallery, **Search Gallery** → "Velo – Consent
   Mode Bridge" → **Add to workspace**).
3. Create a **Custom Event** trigger matching the event name the bridge
   snippet pushes (`velo_consent_update`).
4. Add a tag using the "Velo – Consent Mode Bridge" template, firing on that
   trigger. The `dataLayerKey` field defaults to `velo_categories`, matching
   the bridge snippet's default — only change it if you changed the bridge
   snippet too.
5. Publish the container version.

Full install guide, including direct-snippet and region-behaviour details:
https://veloconsent.com/google-tag-manager

## Keeping the consent mapping honest

This template's sandboxed JS is a hand-kept copy of Velo's SDK-side consent
mapping, because GTM's sandbox has no module loader to share a real import
across the boundary. If Velo's mapping ever changes (a new category, a
different Consent Mode signal), this template's copy has to change with it in
the same release — see the source-of-truth SDK and the rest of the Velo
codebase at https://github.com/leonaves/velo.

## Support

Open an issue on this repository, or see https://veloconsent.com/help.
