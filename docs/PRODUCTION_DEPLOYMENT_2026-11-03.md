# Website publication — November 3, 2026

The owner approved publication of the reviewed website. It is live at
https://www.nibmotion.xyz.

- Production deployment: `dpl_5jiSv3LcwzQbzavB1t5Dy2RTGoaj`, READY.
- Reviewed preview: `dpl_BBisS8t3XTwvYDDwoLRViCct3LPy`.
- Previous production: `dpl_6DES9YBHeZkX6LmZC6nUAozcdmWg`.
- Project: `nib-website`, `prj_LP8bODFk3QYDXwYYBoHEpsTouQZd`.

The production artifact uses the exact reviewed Flutter JavaScript and
WebAssembly builds. Manifest comparison confirms that all application assets,
source exports, images and guide text match the preview. Only HTML indexing
metadata and route response headers changed for production. No Flutter rebuild
or product changes were made during publication.

## Verification

All 208 static route checks passed before uploading the prebuilt artifact.
All 90 unauthenticated production HTTP checks passed afterward. They verified
page content and artifact hashes, canonical URLs, production indexing, the
Motion guides and Markdown exports, relevant playgrounds, social image,
JavaScript/WebAssembly delivery, redirects and the expected 404.

The main domain resolves to the new production deployment. A real-browser check
loaded the Flutter homepage, followed Docs navigation, opened Your first
animation, and activated Save idea with Enter. The card changed to Saved to
your collection and Undo save. No console errors were recorded.

Evidence: `evidence/2026-11-03-production/`. The deployment log, before/after
manifests, artifact comparison and public HTTP results are retained there.

Package versions, PRs, release tags and pub.dev publication were not changed.
Cross-browser and physical-device checks were not repeated for this upload;
the application bytes are identical to the approved preview.

## Rollback

If a production regression requires restoring the immediately preceding site,
run from WebsiteEmberLiving:

```bash
vercel rollback dpl_6DES9YBHeZkX6LmZC6nUAozcdmWg --yes --scope team_uLkGKaENnuPQXup2m6SleSHd
```

This command is recorded for recovery and was not executed.
