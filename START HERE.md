# CVM Assessment — getting it onto your iPhone or iPad

A native iOS app. Everything is here; you need a Mac, Xcode, a USB cable and about
30 minutes the first time (most of it Xcode downloading).

---

## 1. Install Xcode

Open the **App Store** on your Mac, search **Xcode**, click Get. It's free.

It's a large download — roughly 8–10 GB, and it expands to more than that, so make
sure you have ~40 GB free. Leave it running; it takes a while.

If the App Store says Xcode needs a newer macOS than you have, install the latest
version it does offer you, or download an older Xcode from
<https://developer.apple.com/download/all/> (free Apple ID sign-in required). This
project needs **Xcode 15 or later**.

When Xcode first opens it will ask to install additional components — say yes, and
enter your Mac password.

---

## 2. Add your Apple ID to Xcode

This is what lets you sign the app. A **free** Apple ID is enough — no paid
Developer Program needed.

1. Xcode menu → **Settings…** → **Accounts** tab
2. Click **+** at the bottom left → **Apple ID** → sign in with your normal Apple ID

---

## 3. Open the project

Double-click **CVMAssessment.xcodeproj** in this folder.

Xcode opens with the project on the left. You'll see two Swift files, an
`Assets.xcassets`, and a `Web` folder containing the assessment itself.

> If Xcode refuses to open the project file, use the fallback at the bottom of this
> document — it takes about five minutes and produces the same app.

---

## 4. Set the signing team

1. Click the blue **CVMAssessment** icon at the very top of the left sidebar
2. Select the **CVM Assessment** target in the middle pane
3. Open the **Signing & Capabilities** tab
4. Tick **Automatically manage signing** if it isn't already
5. Set **Team** to your name (it will read something like *Pete Fischer (Personal Team)*)

If you get a red error saying the bundle identifier is unavailable, change
**Bundle Identifier** to something else unique — e.g.
`ai.brooklynsolutions.cvmassessment2` — and the error clears.

---

## 5. Run it

**On the simulator first** (quickest sanity check — no cable needed):

1. In the toolbar at the top, click the device selector and pick any iPhone or iPad
   simulator
2. Press the **▶︎ Play** button, or ⌘R

The simulator boots and the app appears. Note that anything you type into the
simulator stays in the simulator — it is not your real device.

**On your actual iPhone or iPad:**

1. Plug it into the Mac with a cable
2. Unlock the device; tap **Trust** if it asks
3. Pick your device from the toolbar device selector
4. Press ▶︎

The first run fails with *"Untrusted Developer"* — this is expected. On the device:

**Settings → General → VPN & Device Management → Developer App →** your Apple ID
**→ Trust**

Then press ▶︎ in Xcode again. The app installs with its own icon and stays on the
home screen.

---

## The one catch with a free Apple ID

Apps signed with a free Apple ID **stop working after 7 days**. The app stays on the
home screen but refuses to launch. To fix it: plug in, press ▶︎ in Xcode again. Your
saved answers survive this — they live in the app's own storage, not in the signing.

Free-account limits worth knowing:

- 7-day expiry, re-run from Xcode to renew
- Up to 3 apps installed this way at a time
- Only devices you physically connect to your Mac
- You cannot send the app to anyone else

A **paid Apple Developer Program** membership (£79/$99 a year) removes all of that:
one-year signing, and TestFlight so you can email an install link to colleagues or
clients — up to 100 internal and 10,000 external testers, no App Store listing
required. That's the natural next step if other assessors need it on their own
devices. **Export JSON regularly** either way — it's your backup.

---

## What's in the app

- All **350 questions** across the 7 assessment areas, grouped by subject exactly as
  in the workbook
- A **Self / External** switch — score as either assessor; the other lane's score
  shows alongside for reference
- **1–8 maturity scale** with level names. The names are a generic maturity ladder I
  supplied because the workbook didn't contain definitions — send me yours and
  they'll be swapped in
- **Notes** per question per lane
- **Dashboard**: the workbook's charts rebuilt — a **radar (spider) profile** and a
  **grouped bar** of Self vs External, with the **Assessment Area slicer** above them and
  a **By area / By subject** toggle for the two pivot levels. Tap a point or bar for its
  figures, or "Show table view" for the numbers as text. Also the largest divergences,
  with a tap through to any question
- **Export**: CSV with the same columns as the comparison workbook (opens straight
  into Excel), and JSON for backup and restore
- Works entirely **offline** — no server, no account, no network permission

The Manhattan Services data from the workbook is preloaded so the dashboard is
populated. **Setup → Start a blank assessment** clears it; **Reload workbook data**
puts it back.

One note on that preloaded data: in the workbook, six of the seven areas have
identical self and external scores — the import macro appears to have pulled the
same source file into both columns. Only Core Supply Chain shows genuine divergence.
That's why most areas read "aligned" on the dashboard. Re-run the workbook's two
import macros against the correct source files and the picture will change.

---

## Fallback: if the project file won't open

Rare, but if Xcode complains the project is damaged, build it yourself in five
minutes:

1. Xcode → **File → New → Project…**
2. **iOS** tab → **App** → Next
3. Product Name: `CVM Assessment` · Interface: **SwiftUI** · Language: **Swift** ·
   leave the test boxes unticked → Next → save it anywhere
4. In the new project, delete the `ContentView.swift` file and the
   `CVM_AssessmentApp.swift` file Xcode generated (Move to Trash)
5. Drag **CVMAssessmentApp.swift** and **AssessmentView.swift** from this folder into
   the project's yellow folder in the sidebar — tick **Copy items if needed**
6. Drag the **Web** folder in the same way. In the dialog, choose **Create folder
   references** (not groups) — this matters, the app looks for `Web/index.html`
7. Optionally drag `Assets.xcassets` in too, replacing the generated one, for the icon
8. Continue from step 4 above (signing)

---

## Changing things later

The entire assessment — questions, scale, dashboard, styling — is the single file
`CVMAssessment/Web/index.html`. Edit it and re-run; no rebuilding of anything else.
The two Swift files only provide the native shell, the share sheet and the haptics.
