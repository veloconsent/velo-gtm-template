___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Velo – Consent Mode Bridge",
  "categories": ["ANALYTICS"],
  "brand": {
    "id": "brand_amplio_data",
    "displayName": "Amplio Data",
    "thumbnail": "data:image/png;base64,"
  },
  "description": "Reads the consent decision Velo already recorded on the page (via a small data-layer bridge snippet — see this repo's docs/INSTALL.md) and forwards it to Google Consent Mode v2 using the exact same category-to-signal mapping as the Velo SDK, so a site that installs Velo through GTM behaves identically to one that installs the snippet directly.",
  "containerContexts": ["WEB"]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "dataLayerKey",
    "displayName": "Data layer key holding Velo's consent categories",
    "simpleValueType": true,
    "defaultValue": "velo_categories",
    "help": "The data layer variable the bridge snippet writes Velo's category object to before pushing the trigger event (default: velo_categories). Must match whatever key the bridge snippet on the page actually uses.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "debugMode",
    "checkboxText": "Log the consent update to the browser console",
    "simpleValueType": true,
    "defaultValue": false,
    "help": "Useful while wiring up the trigger for the first time. Leave off in production — this only affects console.log, never what's sent to Google."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const copyFromDataLayer = require('copyFromDataLayer');
const updateConsentState = require('updateConsentState');
const logToConsole = require('logToConsole');
const makeString = require('makeString');

// This mapping is a deliberate, faithful copy of
// packages/banner-sdk/src/payload.js's gtagConsentFromCategories — the two
// must never drift, so a site installed via the direct snippet and a site
// installed via this GTM template apply the exact same Consent Mode v2 signals
// for the exact same category decision. If that function ever changes, this
// one has to change with it (there is no shared import here: GTM's sandboxed
// JS runs in its own restricted VM with no module loader, so this is a
// hand-kept copy, not a build artifact).
function gtagConsentFromCategories(categories) {
  const c = categories || {};
  const granted = function (flag) {
    return flag === true ? 'granted' : 'denied';
  };
  return {
    ad_storage: granted(c.ads),
    ad_user_data: granted(c.ads),
    ad_personalization: granted(c.ads),
    analytics_storage: granted(c.analytics),
    functionality_storage: granted(c.functional),
    personalization_storage: granted(c.personalization),
    security_storage: 'granted',
  };
}

const dataLayerKey = makeString(data.dataLayerKey || 'velo_categories');
const categories = copyFromDataLayer(dataLayerKey);

if (!categories) {
  // Nothing to forward yet — most likely this tag's trigger fired before the
  // bridge snippet pushed Velo's categories onto the data layer, or the key
  // name in the tag's configuration doesn't match the bridge snippet. Fail
  // rather than silently sending a denied-everything update that could look
  // like a real (and wrong) decision.
  logToConsole(
    'Velo Consent Mode Bridge: no categories found at data layer key "' +
      dataLayerKey +
      '" — nothing to update. Check that the bridge snippet ran before this tag fired.'
  );
  data.gtmOnFailure();
} else {
  const consentUpdate = gtagConsentFromCategories(categories);
  if (data.debugMode) {
    logToConsole('Velo Consent Mode Bridge: updating consent state', consentUpdate);
  }
  updateConsentState(consentUpdate);
  data.gtmOnSuccess();
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "velo_categories"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [{ "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" }],
                "mapValue": [{ "type": 1, "string": "ad_storage" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true }]
              },
              {
                "type": 3,
                "mapKey": [{ "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" }],
                "mapValue": [{ "type": 1, "string": "ad_user_data" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true }]
              },
              {
                "type": 3,
                "mapKey": [{ "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" }],
                "mapValue": [{ "type": 1, "string": "ad_personalization" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true }]
              },
              {
                "type": 3,
                "mapKey": [{ "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" }],
                "mapValue": [{ "type": 1, "string": "analytics_storage" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true }]
              },
              {
                "type": 3,
                "mapKey": [{ "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" }],
                "mapValue": [{ "type": 1, "string": "functionality_storage" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true }]
              },
              {
                "type": 3,
                "mapKey": [{ "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" }],
                "mapValue": [{ "type": 1, "string": "personalization_storage" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true }]
              },
              {
                "type": 3,
                "mapKey": [{ "type": 1, "string": "consentType" }, { "type": 1, "string": "read" }, { "type": 1, "string": "write" }],
                "mapValue": [{ "type": 1, "string": "security_storage" }, { "type": 8, "boolean": false }, { "type": 8, "boolean": true }]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: 'Forwards a mixed consent decision using the SDK''s exact mapping'
  code: |-
    const mockData = {
      dataLayerKey: 'velo_categories',
      debugMode: false
    };

    mock('copyFromDataLayer', function(key) {
      assertThat(key).isEqualTo('velo_categories');
      return { analytics: true, ads: false, functional: true, personalization: false };
    });

    let updateCalledWith = null;
    mock('updateConsentState', function(consent) {
      updateCalledWith = consent;
    });

    mock('logToConsole', function() {});

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();
    assertThat(updateCalledWith).isEqualTo({
      ad_storage: 'denied',
      ad_user_data: 'denied',
      ad_personalization: 'denied',
      analytics_storage: 'granted',
      functionality_storage: 'granted',
      personalization_storage: 'denied',
      security_storage: 'granted'
    });
- name: 'Fails (not just silently no-ops) when the data layer key is missing'
  code: |-
    const mockData = {
      dataLayerKey: 'velo_categories',
      debugMode: false
    };

    mock('copyFromDataLayer', function() {
      return undefined;
    });

    mock('updateConsentState', function() {
      fail('updateConsentState should not be called with no categories to forward');
    });

    mock('logToConsole', function() {});

    runCode(mockData);

    assertApi('gtmOnFailure').wasCalled();
    assertApi('gtmOnSuccess').wasNotCalled();
setup: |-


___NOTES___

Created for Velo (a product of Amplio Data). Bridges Velo's own consent decision
into Google Consent Mode v2 for sites that manage their tags through Google Tag
Manager instead of editing page markup directly.

What this tag does NOT do: it does not read Velo's consent event off the
window directly. GTM's own trigger system (Custom Event triggers, etc.) reads
the data layer, not arbitrary native browser events — and Velo's SDK dispatches
its decision as a native `window` CustomEvent (`velo:consent`), not a
`dataLayer.push`. So a small bridge snippet (a few lines, given in full in this
repo's docs/INSTALL.md) is required on the page to forward that event onto the
data layer; this tag then reads it from there. This is the same shape as every
other CMP-to-GTM integration on the gallery (Cookiebot, OneTrust, Usercentrics,
etc.) — none of them read a CMP's native events directly either.

Versioning: keep gtagConsentFromCategories in this file's sandboxed JS in
lockstep with packages/banner-sdk/src/payload.js's function of the same name.
They cannot share a real import (GTM's sandbox has no module loader), so this
is a deliberate, commented duplicate — any change to the SDK's mapping needs
a matching change here, and vice versa.

// VELO-STUB: submitting this template to the public Community Template
// Gallery (Google's review + listing process at
// https://tagmanager.google.com/gallery) has not been done. Importing and
// using it privately in any GTM container (Templates -> New -> Import) works
// today with no further steps.
