---
product: The web app and the secure test window
also_known_as: [the app, the website, popup, fullscreen, hardware check, camera check, screen share, secure mode]
audience: [candidate]
internal_service: algojobs_frontend
last_verified: 2026-09-18
---

# The web app and the secure test window

This file covers how to use the app itself, and — most importantly — everything that happens
between clicking **Start** on an assessment and seeing question 1. That sequence generates more
support questions than any other part of the platform.

## 1. What this is

AlgoJob runs entirely in a web browser. Proctored assessments run in a **separate, dedicated
window** that goes full screen, runs a set of hardware checks, and asks you to share your screen
before the test begins.

## 2. Who this applies to

Every candidate taking a proctored assessment. AI interviews work differently — they run in the
normal window and need camera and microphone but not screen sharing. See `40-ai-mock-interview.md`.

## 3. Names and terms

| A user might say | Meaning |
|---|---|
| popup, new window, the test window | the dedicated assessment window |
| secure mode, fullscreen | the full-screen state the test runs in |
| hardware check, system check | the camera/mic/network checks before the test |
| screen share | sharing your screen, required before a proctored test starts |
| device busy | another app is holding your camera or microphone |

## 4. Getting into a proctored test, step by step

There are exactly **two clicks** between the window opening and your first question.

1. **Click Start** on the assessment page. A new, screen-sized window opens immediately.
2. **Read the rules, then click "Enter secure mode"** — click one. The window goes full screen.
3. **The hardware checks run by themselves.** You will see a short checklist. If everything passes
   you will not have to do anything — no cards, no buttons. Checks run in this order:

   | # | Check | What it is for |
   |---|---|---|
   | 1 | Browser | Your browser supports what the test needs |
   | 2 | **Other apps using your camera/mic** | Catches Zoom, Meet or Teams holding your devices |
   | 3 | Camera | Your webcam works |
   | 4 | Microphone | Your microphone works |
   | 5 | Speaker | Audio output works |
   | 6 | Screen share | You can share your screen |
   | 7 | Single monitor | You are not on a second display |
   | 8 | Network | Your connection is good enough |

   A card only appears if something **fails**, with instructions to fix it. Fix it, retry, and the
   sequence carries on.
4. **The final gate** shows the results, a live preview of your camera, and a confirmation that you
   have closed other apps. **Click the button** — click two. This starts screen sharing and begins
   the test.
5. **Your clock starts here**, not when you opened the window. Time spent on the checks does not
   come out of your test time.

## 5. During the test

- **Stay in full screen.** Leaving it is detected.
- **Stay on the test window.** Switching tabs or windows is detected.
- **Keep screen sharing on.** Stopping it is detected.
- **Copy, paste, right-click and certain keyboard shortcuts are blocked.**
- **Do not move to a second monitor**, or connect one.
- The support messenger is **switched off** during a proctored test. Finish or exit first.

The rules screen before each test lists exactly what applies to that assessment and how many
warnings you get. See `42-proctoring-and-integrity.md` for how warnings escalate.

## 6. Finishing

- When you submit, or the time expires, the test ends.
- **No score is shown on the final screen.** This is intentional — go to **Report**.
- The window tells you the test has ended and offers a **Close window** button. The page you started
  from moves on by itself.
- If your browser never manages to submit — you lost connection at the very end, for example — the
  attempt is submitted on your behalf automatically. You do not lose the work.

## 7. When things go wrong

### "Nothing happened when I clicked Start" / "the test window did not open"
Your browser blocked the pop-up. **There is no same-tab fallback** — you must allow pop-ups for the
site and click Start again. In most browsers a blocked-popup icon appears at the right-hand end of
the address bar; allow it there, then retry.

### "A check failed and I cannot get past it"
Each failed check explains what to do.
- **Camera or microphone failed** — the permission is blocked, or another app has the device.
  Close Zoom, Google Meet and Microsoft Teams completely, then allow the permission in your browser
  and retry.
- **"Other apps using your camera"** — exactly what it says. Quit those apps, do not just close the
  window.
- **Single monitor failed** — disconnect the second display.
- **Network failed** — move closer to your router or switch to a more stable connection.

### "It says my camera is in use but I closed Zoom"
Closing the window is not enough for some apps — quit them fully. On a Mac, check the menu bar; on
Windows, check the system tray.

### "My browser will not let me share my screen"
Screen sharing must be granted in the browser prompt. If you dismissed it, retry the final step and
accept the prompt. Choose to share your **entire screen**, not a single window, if given the choice.

### "I accidentally left full screen"
Before the test starts, you are simply asked to go back — it does not count against you. **During
the test it counts as a warning.** Return to full screen immediately.

### "I closed the window by accident"
Reopen the assessment. If the assessment supports resuming, you will pick up where you were; if
not, the attempt is finished and scored on what you completed. Either way the attempt has been used.

### "My test ended by itself"
Either the time expired or you reached the warning limit for that assessment. Your report shows how
the attempt ended.

### "The test froze"
Your answers are saved as you go. Reload the window — if the assessment supports resuming you will
return to where you were.

### "I cannot find my score"
Proctored tests never show a score on the final screen. Open **Report**.

### "The support chat disappeared"
It is deliberately turned off during proctored tests and live interviews. It comes back when you
leave.

## 8. Common questions

**Which browser should I use?**
A current desktop version of Chrome or Edge is the safest choice. Keep it updated.

**Can I take a test on my phone?**
No. Proctored assessments need a desktop or laptop with a webcam.

**Do I need to share my screen for an AI interview?**
No. Interviews need camera and microphone only. Screen sharing is for proctored assessments.

**Why does it need my whole screen?**
Screen sharing is part of the integrity check for proctored assessments and you consent to it
explicitly at the final step before the test starts.

**Does the setup time count against my test time?**
No. Your clock starts when you click the final button, not when the window opened.

**Can I use two monitors?**
No. The single-monitor check will fail and connecting a second display during the test is detected.

**What if my internet drops mid-test?**
Your answers are saved as you go. Reconnect and reload. If you never manage to submit, the attempt
is submitted for you automatically.

**Can I go back to a previous question?**
It depends on the assessment. The rules screen before the test tells you.

**Why can I not copy and paste?**
It is blocked during proctored assessments.

## 9. What this does not do

- There is no mobile app and proctored tests do not work on phones.
- There is no same-tab fallback if the pop-up is blocked.
- No score is shown at the end of a proctored test.
- The support messenger is not available during a test or interview.
- The platform does not read your files or your screen contents — it observes the camera, the
  microphone and the screen share you explicitly granted.

## 10. When to contact support

- The pop-up opens but the hardware checks never complete on a working camera and microphone.
- A test window that closes itself repeatedly.
- An attempt consumed with no report and no score.
- Persistent check failures on hardware you have verified works elsewhere.
