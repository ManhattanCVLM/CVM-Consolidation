# Running an assessment across several assessors

The short version: everyone fills in their part on their own device, exports one JSON
file, sends it to you, and you import them all. You get one consolidated assessment and a
client-ready PDF.

---

## What a consolidation holds

**Both assessments at once** — a self assessment and an external assessment — and **each
one is built from as many assessors as it takes**. Four people on the self side and three
on the external side is an ordinary case, not a special one.

That is why the consolidator has no "assessment type" setting. "This is the self
assessment" is a statement about one assessor's submission, not about your consolidation,
and the earlier build asking you to pick one made it look as though a consolidation could
only hold one side. Instead, **Setup → What this copy is doing** offers:

- **Consolidating** — self and external, many assessors (the normal state)
- **Comparing two finished assessments** — the client-facing comparison, still available
  here when you want it

Each submission is filed into one of the two sides as you import it, and the two never mix:
a self answer and an external answer to the same question are held separately, averaged
separately, and annotated separately.

**Setup → The two assessments being consolidated** shows each side's coverage — how many of
the 350 are answered, which assessors contributed and how many answers each, and how many
questions had to be averaged. It is the "have I got enough back yet" view, per side.

---

## Before you send it out

Open **Setup** and fill in two things:

**Client** — e.g. `Manhattan Services`

**Assessment title / reference** — e.g. `2026 Baseline Review`

The title is the important addition. It's what keeps two engagements for the same client
apart. When you import a submission whose client *or* title differs from the one you're
consolidating into, the app stops and shows you both labels before merging — so a file
from last year's review can't quietly fold itself into this year's numbers. You can still
say "merge anyway" when you mean to.

Tell each assessor to set the **same client and title**, plus **their own name** in the
*Your name* field, and whether they're completing the **self** or **external**
assessment. Their name is what identifies their scores once everything is combined, so
the app now shows a warning in Setup while that field is empty.

You don't need to give people cut-down versions. Everyone gets the same app; tell them
which sections to do and leave the rest blank. Blanks merge harmlessly.

---

## What they send you

**Setup → Export my assessment (JSON)**. One file, downloaded like any other — mail it,
drop it in a shared folder, whatever suits.

That same file is their backup, so it's worth them keeping a copy.

---

## Combining

**Setup → Combine assessments → Import & combine submissions.** Select as many files as
you like at once.

### The review step

Nothing merges until you have looked at it. Each file is read and shown with:

- **who sent it** and the client / assessment title it is labelled with
- **how many answers it holds, and in which lane** — e.g. `12 self answers`
- a **warning** if its client or title differs from the assessment you are consolidating
- a running tally at the bottom: *"This import adds 34 self and 12 external answers"*

**Confirming the lane.** For any file whose answers sit entirely in one lane, you get a
three-way choice: **As saved · Self · External**. This is the fix for the one mistake the
app cannot spot by itself — an assessor asked to complete the *external* assessment who
left the switch on Self. Their scores are perfectly good, just in the wrong lane, and only
you know that. Pick **External** and the whole submission, notes included, moves across
before it merges.

Where a file has answers in **both** lanes, no override is offered and it imports as saved.
Moving those would mean guessing which score was which, so it is deliberately left alone.

**Cancel** discards the lot and nothing is touched.

The rules, exactly as you specified them:

| Situation | Result |
|---|---|
| One assessor answered, another left it blank | The answer is taken |
| Two or more answered the same question | Their scores are **averaged**, and both scores are recorded in that question's notes |
| An average lands between levels (4 and 5 → 4.5) | **Rounded down** — every score stays a valid 1–8 level |
| Everyone gave the same score | That score, no annotation needed |
| You tap a score yourself afterwards | Yours wins; the contributions stay on record |

Notes are never overwritten. Each contributor's text is kept and attributed by name, so
two people commenting on the same question gives you both comments, not the last one in.

Re-importing the same file twice changes nothing — contributions are recognised, not
blindly appended — so there's no harm in being unsure whether you already did one.

**Undo last import** appears after any merge and rolls the whole step back. Beyond that
one step, your safety net is exporting a JSON before you start combining.

### Correcting a score on either side

Averages are a starting point, not a verdict. On the **Assess** screen the consolidator
carries a **Moderating: Self | External** switch at the top — it decides which of the two
assessments a score *you* type lands in. Tap a number and it overrides the average on that
side only; the contributing scores stay on record and the note says you set it.

The assessor editions have no such switch on purpose: their lane is fixed so a score
cannot be filed against the wrong side. The consolidator is the one place where choosing
is the whole point.

### Reviewing what was averaged

Setup tells you how many questions had more than one answer. To see them: **Assess →** any
area **→ the "Averaged" chip** in the filter row. Each shows a line like:

> Averaged from 3 assessors (Jane Okafor 6, Bob Reyes 5, Priya Shah 2) → 4.33, rounded down to 4

Where the spread is that wide, an average may not be the answer you want — tap a score to
override it. The note then records that you set it, and who had said what.

The same working appears in the CSV's notes columns, plus two extra columns listing every
assessor and their score per question.

---

## Sending it to the client

**Setup → Create PDF Report → Create PDF report.**

You get: a cover page with the title, client, date and contributors; an executive summary
that reads the self-vs-external gap and names the weakest areas; the radar and bar charts;
a table per assessment area broken down by subject; the fifteen largest divergences; and a
method section with the scale definitions and how consolidation worked.

There's a tick-box for an **appendix of all 350 questions** with their scores and notes.
Off, the report is about 11 pages. On, about 38. Off is usually right for a client;
on is useful when they want to see the evidence.

The report opens in a new tab and prints, so choose **Save as PDF** in the print dialog.
That works the same on Windows, macOS, Android and iOS.

---
