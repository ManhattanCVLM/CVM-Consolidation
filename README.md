# CVM Consolidation — the consolidator

Merges submissions from many contributors into one assessment, then produces the
client report. Same 350 questions, same charts, same report as the client app — plus the
one thing the client editions cannot do.

Hosted as its own Pages site, installable to a home screen, and works with no network
once installed. Identical treatment to the Self and External editions, so it behaves the
same way on the same devices.

```
https://YOUR-USERNAME.github.io/CVM-Consolidation/
```

---

## What being public means

You have chosen to publish this. Be clear about what that does and does not expose:

**It does not expose anyone's results.** There is no server and no database. Every score
and note lives in the browser that entered it. Publishing this publishes the blank tool.

**It does expose the merging capability.** Anyone with the URL can open it, import JSON
exports *they already hold*, and merge them. They cannot reach your assessments — only
files on their own machine. So the risk is not a leak; it is that a client who finds the
URL can consolidate their own contributors' submissions and see the workings, rather than
receiving a finished report from you.

If that stops being acceptable, the fix is **Settings → Pages → Source: None**, which
takes the URL away. Do not reach for a passcode prompt or a list of permitted names
instead: both run on the visitor's machine with no server to enforce them and can be read
straight out of the page source. That looks like access control without being any. Pages
sites are public even from a private repository — access-controlled Pages is
Enterprise-only — so making the repo private would not hide the site either. Turning
Pages off is the whole of the protection.

The URL is not guessable, and nothing links to it. That is not security, but it is the
reason casual discovery is unlikely.

---

## What is in here

```
index.html                the consolidator, hosted build
sw.js  manifest.webmanifest  icon-*.png  .nojekyll     offline install
CVM Consolidator (single file).html                    one file, for a laptop or email
MULTI-ASSESSOR-WORKFLOW.md   collecting submissions, and the merge rules in full
```

---

## Two ways to run it

**Hosted** — open the Pages URL, then Share → Add to Home Screen. It installs as its own
app with its own navy icon and runs offline from then on.

**One file** — open `CVM Consolidator (single file).html` in any browser. No server, no
install, no build step. Email it to yourself and it still works.

Each app installs separately, so the consolidator and the client editions can sit side by
side on one device without replacing each other.

Every edition holds its answers under a storage key of its own
(`cvm-consolidate-v1` here), so the consolidator's working data never mixes with the
client editions, even installed side by side on one device from one origin.

---

## What it can do that the client editions cannot

- **Combine assessments** — import many contributors' JSON exports and merge them: blanks
  filled from whoever answered, collisions averaged and **rounded down**, both source
  scores recorded in that question's notes, a review step before anything is written, and
  one-step undo afterwards
- Everything the client app does: scoring, comparison of two assessments, the charts, the
  PDF report

## It holds both assessments, each from many assessors

A consolidation is **a self assessment and an external assessment together**, and each of
those is built from **as many assessors as it takes** — four people on the self side and
three on the external side is an ordinary case. The two sides are held, averaged and
annotated separately and never mix.

So there is no "assessment type" to set here. That setting describes one assessor's
submission, not your consolidation, and asking for it made it look as though only one side
could be held. **Setup → What this copy is doing** offers *Consolidating* (the normal
state) or *Comparing two finished assessments*.

**Setup → The two assessments being consolidated** shows each side's coverage: how many of
the 350 are answered, which assessors contributed and how many answers each, and how many
questions had to be averaged.

**Assess → Moderating: Self | External** decides which side a score you type yourself lands
in, so you can correct either without touching a setting. The assessor editions have no such
switch by design — their side is fixed so a score cannot be filed against the wrong one.

With both sides populated, the dashboard and report label the two series **Self** and
**External** and show the alignment and the largest gaps. Consolidate only self submissions
and they name the single series after the assessment's own title instead, and drop the gap
columns — the same rule the client editions follow.

The merging engine is **physically absent** from the client builds — stripped at build
time, not hidden behind a flag. Opening a client edition's source and hunting for it will
not find it; it was never compiled in. The build asserts this on the built artefact of
every edition, so a wiring mistake fails the build rather than shipping.

That is also why these two repositories have separate histories: one shared history would
leave merge-capable code recoverable from an earlier commit.

---

## Licensing

This app is **not** licensed or time-limited — it is your tool, and locking yourself out
mid-consolidation would help nobody. The three client-facing apps do carry a licence; see
the `CVM-Assessment` README, and keep `CVM Licence Keys (KEEP PRIVATE).html` off every
repository.

---

## How an update reaches people

**The page is fetched from the network first**, with the cached copy as the fallback. So a
reload with any signal at all lands on the current version — one reload, not two — and the
app still opens instantly with no network.

That is a change from how it worked up to build 2.5, which served the cached copy every
time and fetched the new one quietly for next time. The first visit after an update showed
the old app, which reads exactly like the update having failed.

**A release made while somebody has the app open** shows them *"A new version is ready"*
with a Reload now button. Nothing is swapped underneath them mid-question, and their
answers survive either way.

**Installed copies check on every open**, and the worker script itself is exempt from the
browser's HTTP cache (`updateViaCache: "none"`), so a new release cannot sit unnoticed
behind a stale copy of `sw.js`.

**If the site is ever switched off** — Pages turned off, the repository made private on a
free plan, a deploy that fails — an installed copy keeps working from its cache. The worker
treats a 404 or a 500 as a failed fetch, not as the app, so a hosting error never replaces
a working install. New visitors get nothing, of course.

To release: replace `index.html`, **bump `const CACHE` in `sw.js`**, commit. Without the
bump, devices keep the assets they cached — the page will be current but its icons and
manifest will not.

If a device is somehow still stuck: in the browser, clear site data for the URL; on a
home-screen install, delete the icon and add it again. Answers live in the browser's
storage for that origin and survive the first; the second clears them, so export first.

---

## Releasing a change

1. Replace `index.html`
2. **Bump `const CACHE` in `sw.js`** — currently `cvm-consolidate-v20`
3. Commit and push; Pages redeploys within a minute

Without step 2, a device that already installed it keeps serving its cached copy. Answers
already on a device survive an update.

---

## Companion repository

**`CVM-Assessment`** — the client app plus the locked Self and External editions that
assessors use. Nothing in this repository belongs there.

---

© Brooklyn Solutions AI / Manhattan CVLM. All rights reserved. Published here for
distribution to named clients; not licensed for reuse or redistribution.
