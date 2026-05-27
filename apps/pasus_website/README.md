# Pasus Anti-Malware Website

Premium marketing website for Pasus Anti-Malware.

```powershell
npm install
npm run dev
npm run build
npm test
```

Waitlist behavior:

- Development stores entries in `.data/waitlist.jsonl`.
- Production requires `PASUS_WAITLIST_JSONL`.
- If storage is unavailable, the form shows an honest failure state.

The site does not include checkout, payment, license-key generation, fake customer reviews, fake awards, or fake certifications.
