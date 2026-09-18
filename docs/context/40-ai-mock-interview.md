---
product: AI Interview
also_known_as: [mock interview, AI interviewer, the bot interview, HR round, AI mock]
audience: [candidate]
internal_service: interview_manager
last_verified: 2026-09-18
---

# AI Interview — booking, running, and your report

## 1. What this is

A live, spoken mock interview conducted by an AI interviewer. You book a time slot, join from your
browser, and talk to the interviewer the way you would in a real screening call. It listens, asks
follow-up questions based on your answers, and at the end produces a scored report with strengths,
gaps and an action plan.

It is a **practice** interview. It is not a real employer interview and no employer sees the
result unless you are taking an interview a recruiter scheduled for you.

## 2. Who can use it

Any candidate with at least **one interview credit**. Credits come from three places:

- Your monthly PRO allowance (1 per month on PRO, 0 on Basic).
- **XP** — every 300 XP you earn converts into 1 interview credit.
- **Top-up packs** you buy.

On the free Basic plan, XP is the route to interviews. See
`21-plans-credits-and-billing.md` and `22-xp-levels-and-rewards.md`.

You also need a reasonably complete profile — the interviewer reads your resume to ask relevant
questions.

## 3. Names and terms

| A user might say | Meaning |
|---|---|
| credit, session, token | one interview credit |
| slot, booking, appointment | the 30-minute window you reserved |
| JD | job description — the role you are being interviewed for |
| round | the interview type: screening, technical, behavioural, or HR |
| transcript | the text record of what you and the interviewer said |
| evaluation | your interview report |

## 4. How it works, step by step

1. **Open AI Interview.** You see your credit balance, your next booked slot, your recent reports
   and the job descriptions available to you.
2. **Choose a role.** Pick one of the available job descriptions, or upload your own as a PDF. The
   interviewer's questions are built from that job description plus your resume.
3. **Book a slot.** Slots are **30 minutes** long. You must have at least one credit to book.
4. **Join at your slot time.** Open the interview from the AI Interview page. Your browser will ask
   for **camera and microphone** permission — both are required.
5. **The interview begins** once your camera and microphone are both connected. The interviewer
   greets you and asks the first question.
6. **Answer out loud.** One question at a time. The interviewer waits for you to finish speaking
   before responding — there is no button to press.
7. **The interviewer wraps up** a few minutes before your time is up: a final question, then a
   chance for you to ask questions, then it ends the call.
8. **Your report is generated** in the background. It appears under **Report**, usually within a
   couple of minutes.

See `41-interview-agent-behaviour.md` for what the interviewer does during the call and every way
a call can end.

## 5. Rules, limits and timings

| Rule | Value |
|---|---|
| Slot length | **30 minutes** |
| Maximum candidates in the same slot | **5** |
| Minimum time left in a slot to still start | **15 minutes** |
| Grace after a slot window closes | 5 minutes, then the slot is marked expired |
| Credits required to book | 1 |
| Camera required | Yes |
| Microphone required | Yes |
| Proctoring | **On by default for every mock interview** |

- **You cannot book a slot you cannot finish.** If fewer than 15 minutes remain in a window, the
  platform refuses the booking with this exact message:
  *"This slot has less than 15 minutes remaining. Please choose another time."*
- **A slot holds a limited number of people.** Once 5 candidates have booked the same window, it is
  full and you must choose another.
- **You can only have one active booking at a time.** Finish or let the current one expire first.
- If you never join a booked slot, it is released automatically after the window closes plus a
  5-minute grace — and your credit comes back (see section 8).

## 6. How scoring works

Your interview is scored from the transcript of what you actually said. Nothing is scored from your
appearance, your accent, or how fast you speak.

**Your overall score (0–100) is the average of six skill scores:**

| Skill | What it measures |
|---|---|
| Technical | Correctness and depth of your technical answers |
| Communication | How clearly you express yourself |
| Problem solving | How you approach an unfamiliar problem |
| Confidence | How assured your answers are |
| Logical reasoning | Whether your reasoning holds together |
| Articulation | Structure and precision of your explanations |

**Your verdict is derived from that overall score, not decided separately:**

| Overall score | Verdict | Readiness | Rejection risk |
|---|---|---|---|
| 80 and above | **Strong Hire** | Yes | Low |
| 60 to 79 | **Hire** | Getting There | Medium |
| Below 60 | **No Hire** | No | High |

The report also scores each individual skill the interview touched, and — on advanced interviews —
compares each one against the threshold the target role expects.

## 7. What you get afterwards

Your report contains:

- **Overall score** and verdict.
- **Skill profile** — the six scores above, each next to an average-hire benchmark.
- **Per-skill insights** — for each skill discussed: a score, how many questions covered it, and a
  specific action plan.
- **Key strengths** and **areas for improvement**.
- **Performance overview** across technical, communication and culture fit.
- **A quick win** — the single highest-value thing to fix first.
- **Final verdict** in plain language.

**Advanced interviews additionally include:** offer probability, a hiring benchmark, a suggested
negotiation range, a behavioural deep-dive (leadership, empathy, handling ambiguity, growth
mindset), a question-by-question breakdown with the ideal answer, critical red flags, recurring
mistake patterns, and a **7-day personalised growth roadmap**.

If your interview was recorded, the recording and the full transcript are saved with the report.

## 8. When things go wrong

### "I joined the interview but there is no report"
The most common cause: **you have to actually answer some questions.** If you spoke fewer than
**four times**, no report is generated at all — there is not enough to score. Your credit is
returned automatically. Book another slot and complete the interview.

### "My report says 'Evaluation Pending' and the score is 0"
This means **our scoring failed**, not that you performed badly. Your transcript was saved. This is
not a reflection of your interview. **Contact support with the interview date and time** — the
report can be re-scored. Do not treat the 0 as a real score.

### "My score is 0 and it says No Hire"
If the interview was **ended for proctoring**, the report is automatically scored 0 with a No Hire
verdict and no AI evaluation is run. Check the report for a termination reason. See
`42-proctoring-and-integrity.md`.

### "The interview ended before I finished"
There are several reasons this happens legitimately — silence, reaching the time limit, proctoring
alerts, or leaving the room. Every one of them is explained in
`41-interview-agent-behaviour.md`, section 5.

### "The interviewer could not hear me"
Your microphone was not granted or not working. The interview does not start until both camera and
microphone are connected, so if the interviewer never spoke, one of them was never granted. Check
your browser's site permissions, make sure no other app (Zoom, Meet, Teams) is holding the
microphone, and rejoin.

### "I lost my credit but the interview did not work"
**You did not lose it.** A credit is held when you start and only actually spent once a report
exists. If no report was produced, the hold is released automatically. This runs on a regular sweep,
so allow up to about an hour for the balance to update. If it has not come back after that, contact
support.

### "I got disconnected mid-interview"
If you rejoin quickly the interview continues. If everyone leaves the room, the interview ends
after a short grace period and is scored on whatever was said. If that was fewer than four answers,
no report is produced and the credit returns.

### "My booked slot disappeared"
Slots expire once their window closes plus a 5-minute grace. An expired slot cannot be resumed —
book a new one. Your credit is returned if the interview never ran.

### "It says I already have an interview in progress"
An earlier session did not close cleanly. It is cleared automatically within a few minutes. Wait
and refresh; if it persists beyond that, contact support.

## 9. Common questions

**How long is an AI interview?**
The slot is 30 minutes. The interviewer starts wrapping up a few minutes before the end.

**Do I need a webcam?**
Yes. Camera and microphone are both required, and the interview will not start without them.

**Is it recorded?**
Interviews may be recorded, and the transcript is saved with your report either way.

**Can I pause the interview?**
No. Once it starts it runs to the end. If you go quiet the interviewer will check on you and, if
there is still no response, end the call.

**Can I retake it?**
Yes, as many times as you have credits for.

**Does a bad score go on my profile or get shown to recruiters?**
Practice interview reports are yours. Recruiters see results for interviews **they** scheduled, not
your practice attempts.

**Can I choose the type of round?**
The round type is set by the job description and configuration for the interview. You choose the
role, not the round format.

**Can I use notes?**
Nothing stops you having notes, but the interview is proctoring-monitored and looking away from the
screen repeatedly will generate alerts. See `42-proctoring-and-integrity.md`.

**What if I do not know an answer?**
Say so and explain how you would approach it. The interviewer will move on cleanly rather than
labour the point — and reasoning aloud scores better than silence.

**How soon is my report ready?**
Usually within a couple of minutes of the call ending. You get a notification.

**Can I get my credit back if I did badly?**
No. A completed interview that produced a report has used its credit. Credits are only returned
when no report was produced.

## 10. What this does not do

- It is not a real job interview and does not result in an offer.
- The interviewer never makes an offer, quotes a salary, or promises next steps.
- It does not coach you during the call — it will not tell you whether an answer was right. The
  feedback is in the report.
- It cannot be paused, rescheduled mid-session, or resumed after it ends.
- It does not score your appearance or your accent.

## 11. When to contact support

- A report that says **"Evaluation Pending"** — always, it needs re-scoring.
- A credit that has not returned more than an hour after a failed interview.
- A charge for a top-up that did not add credits.
- Believing a proctoring termination was wrong (see `42-proctoring-and-integrity.md`).
