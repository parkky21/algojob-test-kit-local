---
product: Proctoring and test integrity
also_known_as: [monitoring, camera check, cheating detection, invigilation, warnings, violations]
audience: [candidate, college_admin]
internal_service: interview-proctoring
last_verified: 2026-09-18
---

# Proctoring — what is monitored and what happens

This is the file for every "am I in trouble?" question. Be accurate and calm: most candidates
asking about proctoring have done nothing wrong and are anxious about a warning they saw.

## 1. What this is

During AI interviews and proctored assessments, your webcam feed is analysed in real time to check
that the person being assessed is you, alone, and focused on the screen. If something looks wrong,
you get an on-screen warning. If warnings keep coming, the session ends and the report is flagged.

**Proctoring is on by default for every AI mock interview.** For assessments, whether proctoring
applies depends on the assessment — the rules screen before you start tells you.

## 2. Who this applies to

Every candidate taking a proctored assessment or an AI interview. College admins can see which
sessions were flagged for their students.

## 3. Names and terms

| A user might say | Meaning |
|---|---|
| warning, alert, violation, strike | one recorded proctoring event |
| flagged, marked, caught | the report records a proctoring termination |
| kicked out, auto-submitted, ended early, proctoring limit | the session was ended at the warning limit |
| the yellow/red button | the warning counter in the interview screen |

## 4. What is monitored

During a **live AI interview**, from your webcam and microphone:

| Checked | What triggers it |
|---|---|
| **Where you are looking** | Looking left, right, up or down away from the screen, held for a couple of seconds |
| **Head position** | Turning or tilting your head away from the screen, held for a couple of seconds |
| **More than one person** | A second person visible in the camera frame |
| **Nobody in frame** | You leave the camera's view |
| **A mobile phone** | A phone visible in the camera frame |
| **More than one voice** | A second speaker heard in the audio |

During a **proctored assessment in the browser**, the test window additionally checks that you stay
in full screen, stay on the test window, keep screen sharing on, do not use copy/paste or the
right-click menu, and do not switch to a second monitor. The rules screen before the test lists
what applies. See `10-web-app-and-test-environment.md`.

## 5. The grace built in before anything counts

This is the section that answers most anxious questions. Proctoring is **deliberately tolerant** —
it is not looking for a single glance.

| Protection | What it means for you |
|---|---|
| **Warm-up period** | For the first few seconds the system learns your normal sitting position. Nothing can be flagged during it. |
| **Your neutral position is learned** | It calibrates to *your* posture and camera angle. Sitting slightly off-centre is not a violation. |
| **Sustained, not instant** | Looking away or turning your head must continue for **about 2 seconds** before it registers. A quick glance is not a violation. A phone needs about half a second; a second person or an empty frame about a second. |
| **Interruptions reset it** | If you look back at the screen, the count starts over. |
| **Repeat cooldown** | The same kind of warning cannot fire more than once every **10 seconds**. |
| **Network glitches do not count** | A dropped connection cannot manufacture a violation. |

## 6. What happens when warnings add up

**During a live interview:**

1. Each alert shows as an on-screen warning and increments a counter you can see.
2. The counter button turns **yellow** when you are one away from the limit, and **red** at the
   limit.
3. At **10 alerts**, the interview is ended automatically.
4. You are shown a message and the session closes after about 10 seconds.

**On the report:** an interview ended for proctoring is marked as terminated, scored **0**, and
given a **No Hire** verdict with high rejection risk. No AI evaluation is run on the transcript. The
list of alerts is saved with the report.

**During a proctored assessment:** the rules screen tells you the limit for that specific
assessment. Depending on the assessment, exceeding it either warns you or ends and submits the test
automatically. Your report shows how the attempt ended.

## 7. What you should do

- **Sit in a quiet room alone**, with a plain background if you can.
- **Face the camera** with your whole face visible and lit from the front, not backlit by a window.
- **Put your phone away** — out of frame entirely. A phone on the desk beside you can be detected.
- **Close Zoom, Google Meet and Microsoft Teams** before you start. They hold your camera and
  microphone and will make the hardware check fail.
- **Do not read from a second screen.** Repeatedly looking off to the side is exactly what the gaze
  check is for.
- **Do not have someone else in the room**, even silently — a second person in frame or a second
  voice both register.
- If you need to look away to think, **look at the screen and think**, or say it out loud.

## 8. When things go wrong

### "I got a warning but I did nothing wrong"
Common innocent causes: someone walked behind you; you looked down at your keyboard for several
seconds; you leaned out of frame; a phone was visible on the desk; a family member spoke nearby. A
single warning has no consequence at all. Only reaching the limit ends a session.

### "Someone walked behind me — am I disqualified?"
One event is a warning, nothing more. There is no consequence unless warnings reach the limit.

### "My interview ended and says I was flagged for cheating"
That means the session reached 10 alerts. The report is scored 0 with a No Hire verdict and the
alert list is saved. If you believe this was wrong — a reflection in a mirror, a poorly placed
camera, a sibling passing repeatedly — **contact support with the interview date and time** and ask
for the session to be reviewed. Do not simply retake it and hope; get the flagged session reviewed.

### "I look away when I think — will that fail me?"
Brief glances are fine. Sustained looking away, repeatedly, is what accumulates. If thinking away
from the screen is how you work, say your thinking out loud instead — it also scores better.

### "My camera makes me look off-centre"
The system learns your normal position during a warm-up, so an angled camera is usually fine.
If your camera is extreme enough that you cannot face it, reposition it before starting rather than
during the session.

### "My glasses / the lighting / my skin tone caused false alerts"
Front-facing light and no strong backlight help most. If you are getting repeated warnings while
sitting still and facing the screen, stop, fix the lighting or camera position, and report it to
support — repeated false alerts are worth investigating.

### "I got no warnings at all — is proctoring working?"
Getting no warnings is the normal outcome for someone sitting still and facing the screen. It does
not mean proctoring was off.

### "I was warned about a second voice but I was alone"
A television, a video playing nearby, or someone on a call in the next room can be picked up. Take
the assessment in a quiet room.

## 9. Common questions

**How many warnings before I am ended?**
**10** in a live interview. Proctored assessments show their own limit on the rules screen before
you begin.

**Does one warning affect my score?**
No. Warnings are recorded but do not reduce your score. Only reaching the limit does, by ending the
session and scoring it 0.

**Can I see how many warnings I have?**
Yes — the counter is visible on the interview screen, and it turns yellow then red as you approach
the limit.

**Is my camera recorded?**
Interviews may be recorded, and the transcript is always saved with your report. Proctoring alerts
are saved with the report too.

**Can I take the test in a shared room / hostel?**
It is strongly discouraged. Other people in frame and other voices both register.

**Can I turn proctoring off?**
No. It is on by default for AI interviews, and for assessments it is part of the assessment's rules.

**Is tab switching tracked during an interview?**
No. During a **live AI interview**, tab switching is not monitored. During a **proctored browser
assessment** it is — the rules screen tells you.

**Does looking at my keyboard count?**
Briefly, no. Sustained looking down for several seconds can register as looking away.

**Who sees my proctoring record?**
It is attached to your report. For interviews a recruiter scheduled, that recruiter sees it. For
college-run assessments, your college admin can see flagged sessions.

**I was ended unfairly. Can I redo it?**
Contact support and ask for the session to be reviewed. Do not just retake it — get the flagged
record looked at.

## 10. What this does not do

- It does not read your screen contents or your files.
- It does not access anything outside the camera, microphone and, for browser assessments, the
  screen share you explicitly granted.
- It does not judge your appearance, clothing, background or accent.
- It does not reduce your score per warning — only ending the session affects the score.
- It does not run when you are not in an assessment or interview.

## 11. When to contact support

- You believe a proctoring termination was wrong — always, with the date and time.
- Repeated warnings while sitting still and facing the camera.
- A report flagged as terminated when your session ended normally.
