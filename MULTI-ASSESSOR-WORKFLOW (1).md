# Running an assessment across several assessors

Build 1.2 adds combining. The short version: everyone fills in their part on their own
device, exports one JSON file, sends it to you, and you import them all. You get one
consolidated assessment and a client-ready PDF.

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

**Setup → Export my assessment (JSON)**. One file. It goes through the normal iOS share
sheet, so AirDrop, Mail or Files all work.

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

**Setup → Send to the client → Create PDF report.**

You get: a cover page with the title, client, date and contributors; an executive summary
that reads the self-vs-external gap and names the weakest areas; the radar and bar charts;
a table per assessment area broken down by subject; the fifteen largest divergences; and a
method section with the scale definitions and how consolidation worked.

There's a tick-box for an **appendix of all 350 questions** with their scores and notes.
Off, the report is about 11 pages. On, about 38. Off is usually right for a client;
on is useful when they want to see the evidence.

On the iPhone the PDF is generated natively and opens the share sheet — mail it straight
from your phone. In a browser or the installed web app it opens in a new tab and prints,
so choose **Save as PDF** (which is also the easiest route if you'd rather do the final
send from your Mac).

---

## One caveat I should flag

The merge logic, the report layout and the PDF pagination I tested properly — synthetic
submissions from three assessors, checked against hand-computed averages, including
three-way collisions, re-imports and overrides.

The **native PDF generation is new Swift code I could not compile or run**, since there's
no macOS in my environment. If **Create PDF report** does nothing or errors on the phone,
that's where the problem is — tell me what it says. The browser route is fully tested, so
you always have a working path to a PDF in the meantime.
