---
product: The AI interviewer (during the call)
also_known_as: [the AI, the bot, the interviewer, the agent, the voice]
audience: [candidate]
internal_service: algojob-agent-server
last_verified: 2026-09-18
---

# What the AI interviewer does during your call

This file covers the live call itself — how the interviewer behaves, how each round differs, and
every way a call can end. For booking, credits and reports see `40-ai-mock-interview.md`.

## 1. What this is

Once you join your interview room, an AI interviewer joins with you. It has read your resume and
the job description for the role. It conducts the interview by voice: it asks a question, listens
until you stop speaking, then responds. There is no push-to-talk button and nothing to click.

## 2. Who can use it

Anyone in an AI Interview session. You do not configure it — the interviewer's behaviour comes
from the role and round your interview was set up with.

## 3. Names and terms

| A user might say | Meaning |
|---|---|
| it cut me off / it interrupted | the interviewer detected you had finished speaking |
| it did not respond | usually a microphone problem, not the interviewer |
| the closing bit, wrap-up | the closure phase at the end |
| STAR | the Situation–Task–Action–Result answer structure used in behavioural rounds |

## 4. How it behaves

**One question at a time.** The interviewer never bundles two questions together. If you are
unclear which part to answer, answer the whole thing — there is only one question.

**It listens for you to finish.** It uses your silence to know your turn has ended. This means:
- Long pauses mid-answer can be read as you finishing. Keep speaking, or say "let me think" out
  loud rather than going silent.
- You can interrupt it while it is speaking, and it will stop and listen.

**It does not coach, praise or correct you.** You will get neutral acknowledgements like "Got it."
or "Understood." — never "Good answer" or "Actually, that's wrong." This is deliberate: praise or
correction mid-interview would change how you answer and make the score meaningless. It is not a
signal that you did badly.

**If your answer is wrong, it will not tell you.** It will pose a different scenario instead. If
you are vague it asks for a specific example. If you are stuck it moves on cleanly.

**It uses the name on your resume**, not whatever your microphone transcribed.

**It does not ask about protected characteristics** — age, religion, marital status, caste,
gender, disability and the like are out of scope by design.

## 5. How the round shapes the questions

| Round | What it does |
|---|---|
| **Screening** | Works across the skills on the job description — introduces a topic, verifies you actually know it, moves to the next. Broad rather than deep. |
| **Technical** | Drills down. Starts at the surface of a topic, then asks about the mechanism, then an edge case, then a trade-off, then how it behaves at scale, then where it breaks. Expect each answer to trigger a harder follow-up — that is the format working, not you failing. |
| **Behavioural** | Expects **STAR** answers: the situation, your task, what *you* did, and the result. If you say "we", it will ask what *you* personally did. It covers ownership, conflict, teamwork, failure and influence, then revisits your weakest answers for the missing piece. |
| **HR / final** | Motivation and culture fit, then logistics: notice period, current and expected salary as a number, location and work-mode preference, and whether you have competing offers. Then your questions. **It never makes an offer.** |

Some interviews run as a single continuous round. Others run in **four phases** — a short
introduction, a longer dig into your projects, a fact-based section, then a behavioural section —
moving between them automatically on a timer.

## 6. How the call ends

There are five ways. All of them are normal and none of them are a bug.

### 1. The interviewer wraps up (the usual way)
A few minutes before your time is up, the interviewer switches into a closing phase: one final
question, then an invitation for you to ask questions, then it ends the call.

### 2. Time runs out
If the conversation overruns, there is a hard stop at your booked duration **plus a 2-minute
grace**. The call ends wherever it is.

### 3. You went silent
If you stop responding, the interviewer escalates gently before giving up:

| Step | What happens |
|---|---|
| After about 15 seconds of no response | *"Take your time — if it helps, you can start by sharing your first thought or approach."* |
| 20 seconds later, still nothing | *"Just checking — are you still with me?"* |
| 20 seconds later, still nothing | *"I'm going to end this interview now. Please try again later."* — and the call ends |

Speaking at any point cancels this and the interview continues normally. Total silence tolerated:
roughly **55 seconds**.

### 4. Proctoring ended it
Ten proctoring alerts end the interview immediately. See `42-proctoring-and-integrity.md`.

### 5. Everyone left the room
If you close the tab or lose connection and do not come back, the interview ends after a short
grace period (about 15 seconds), and rejoining within that window resumes it.

## 7. What you get afterwards

Nothing is shown at the end of the call. The report is produced in the background and appears
under **Report**. See `40-ai-mock-interview.md`, section 7.

## 8. When things go wrong

### "It kept interrupting me"
It treats a pause as the end of your turn. Speak continuously, and fill thinking time out loud
("let me think about that for a second") rather than going quiet.

### "It never said anything"
The interview does not begin until both your camera and microphone are connected. If the
interviewer never spoke, one of them was not granted or is being held by another app. Close Zoom,
Meet or Teams, re-grant permission in your browser, and rejoin.

### "It ignored my question"
The interviewer answers your questions in the closing phase, not during the interview. Save them
for the end.

### "It asked the same thing again"
In technical rounds, near-identical follow-ups are intentional — it is probing the same topic at a
deeper level. Answer the more specific version.

### "It did not react when I gave a great answer"
It is not allowed to praise. Neutral acknowledgement is what every answer gets, good or bad.

### "It ended right after I joined"
If you joined and said nothing, the silence sequence ends the call in under a minute. With fewer
than four answers, no report is produced and your credit is returned automatically.

### "The audio was choppy / it misheard me"
Use a wired headset if you have one, and a quiet room. The transcript is what gets scored, so
background noise and a distant microphone directly cost you marks on communication and
articulation.

## 9. Common questions

**Can I ask it to repeat the question?**
Yes. Just ask — it will rephrase or repeat.

**Can I ask for clarification?**
Yes, and doing so is fine. It reflects better than guessing at what was meant.

**Will it tell me if I got something wrong?**
No, never during the call. That is in the report.

**Can I interrupt it?**
Yes.

**Does it understand Indian English / my accent?**
It is set up for Indian English. Speak at a normal pace and it will follow you. Accent is not
scored.

**Can I answer in Hindi or another language?**
No — answer in English. The interview is conducted and scored in English.

**Does it see me?**
Your camera is used for proctoring, not for scoring. Nothing about your appearance affects your
score.

**What if I need a moment to think?**
Say so out loud. Silence is what triggers the check-in sequence; speech does not.

**Can I end it early myself?**
You can leave the room, and the interview will end. It will be scored on what you said up to that
point — and if that is fewer than four answers, there will be no report at all.

## 10. What this does not do

- It does not coach, hint, praise or correct during the interview.
- It does not make offers, quote salaries or promise next steps.
- It does not ask about protected characteristics.
- It cannot be paused or rewound.
- It does not score your face, your accent, or your background.

## 11. When to contact support

- The interviewer never spoke despite camera and microphone both being granted and working.
- The call ended immediately with no explanation and you were answering normally.
- Anything covered in `40-ai-mock-interview.md`, section 11.
