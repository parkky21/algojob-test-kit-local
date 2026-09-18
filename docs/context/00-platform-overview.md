---
product: AlgoJob platform overview
also_known_as: [AlgoJob, Algojobs, AlgoHR, the platform, the app]
audience: [candidate, recruiter, college_admin, university_admin]
internal_service: all
last_verified: 2026-09-18
---

# AlgoJob — platform overview

This is the index file for the AlgoJob knowledge base. Read it first: it defines who the
users are, what every product is called, and the rules that apply across the whole platform.
Each other file covers one product area in depth.

## 1. What AlgoJob is

AlgoJob is a career-readiness and hiring platform. Students and job seekers practise on it every
day — aptitude tests, spoken English, debugging, coding, and AI-led mock interviews — and get a
report after each attempt that tells them what to fix. Recruiters use the same platform to post
jobs, screen candidates and run AI interview rounds. Colleges and universities use it to track how
their students are progressing and who needs help.

Everything runs in a web browser. There is no mobile app and no desktop download.

## 2. Who uses it

| Persona | What they are called in the product | How they sign in |
|---|---|---|
| **Candidate** | student, job seeker, candidate | `/user/login` or `/student/login` |
| **Recruiter** | HR, AlgoHR user, employer | `/company/login` |
| **College admin** | placement officer, TPO, college admin | `/college/login` |
| **University admin** | university admin | `/university-login` |

A person has one role. A candidate account cannot sign in to the recruiter portal and vice versa.

## 3. The products, by name

Candidates see these in the left-hand menu, in this order:

| Menu name | What it is | Detail file |
|---|---|---|
| **Campus Buzz** | The home feed — posts, likes, follows, achievements | `23-campus-buzz-and-profile.md` |
| **Analytics** | Personal performance dashboard, skill radar, heatmaps | `23-campus-buzz-and-profile.md` |
| **Code Byte** | Five-phase coding evaluation | `33-code-byte-and-coding.md` |
| **Mock Aptitude** | The "Daily 20" — 20 questions across 4 sections | `31-mock-aptitude-daily-20.md` |
| **Mock Debug** | Explain and debug code out loud | `32-debug-arena.md` |
| **Mock SVAR** | Spoken English assessment | `30-svar-spoken-english.md` |
| **AI Interview** | Live AI-led mock interview | `40-ai-mock-interview.md` |
| **Report** | All reports across every product | each product file, section 7 |
| **Payments** | Plans, top-ups, order history, invoices | `21-plans-credits-and-billing.md` |

Together, Mock Aptitude, Mock Debug, Mock SVAR and the coding practice are called **the arenas**.

## 4. Names and terms (aliases → canonical)

Users rarely use the official name. Map these:

| A user might say | They mean |
|---|---|
| communication test, English test, speaking test, AlgoApex, APEX | **Mock SVAR** |
| Daily 20, daily twenty, aptitude, MCQ practice, practice test | **Mock Aptitude** |
| viva, debug viva, code explanation test | **Mock Debug** |
| coding round, DSA practice, the 5-phase test | **Code Byte** |
| mock interview, AI interviewer, the bot interview, HR round | **AI Interview** |
| the feed, posts, buzz | **Campus Buzz** |
| points, coins, XP | **XP** (experience points) |
| credits, sessions, tokens | **credits** — interview credits or assessment credits |
| premium, paid plan, subscription | **PRO** |
| free plan, normal account | **Basic** |
| proctoring, monitoring, camera check, cheating detection | **proctoring** |

⚠️ **XP and credits are different things.** XP is earned by practising and never spent directly;
credits are spent to start an AI interview. XP converts into credits at a fixed rate — see
`22-xp-levels-and-rewards.md`.

## 5. Rules that apply everywhere

- **Plans are Basic (free) and PRO (paid).** There is no other plan. See
  `21-plans-credits-and-billing.md`.
- **PRO raises your limits; it does not unlock products.** Every arena and every basic report is
  available on the free plan. PRO subscribers get more attempts per week, more daily XP, advanced
  reports and cheaper top-ups. This is the most commonly misunderstood thing on the platform.
- **The arena limit is weekly, not daily.** Basic gets **3 attempts per week** of each arena; PRO
  gets **4 per week**. The week resets on a rolling weekly basis, not on a calendar day.
- **Reports are not instant.** Anything scored with speech or AI takes a short while after you
  submit. Check the Report section rather than waiting on the results screen.
- **Practice is single-device, single-session.** Starting the same assessment in two tabs or on two
  devices is blocked.
- **Everything is in English**, and spoken assessments expect English answers.
- **Prices are in Indian Rupees (INR) and shown inclusive of 18% GST at checkout.**

## 6. What happens after you finish an assessment

1. You submit (or the timer runs out, or the test is ended for you).
2. The attempt is recorded immediately and counts against your weekly limit.
3. Scoring runs in the background.
4. The report appears under **Report**, and you get a notification when it is ready.

Scores are never shown on the final screen of a proctored test — that is intentional. Go to
**Report**.

## 7. Support and escalation

Support is available through the in-app messenger on most pages. It is deliberately **turned off
during a proctored test or a live interview** so it cannot be used as a channel during an
assessment. Finish or exit the assessment first.

See `99-escalation-and-limits.md` for the questions that must always go to a human.

## 8. File index

| File | Covers |
|---|---|
| `00-platform-overview.md` | This file |
| `10-web-app-and-test-environment.md` | The web app, the secure test window, hardware checks |
| `20-accounts-and-login.md` | Signing up, signing in, profile, notifications |
| `21-plans-credits-and-billing.md` | Basic vs PRO, prices, top-ups, credits, billing |
| `22-xp-levels-and-rewards.md` | XP, levels, leaderboards, rewards |
| `23-campus-buzz-and-profile.md` | The feed, profile, analytics, referrals |
| `24-recruiter-portal.md` | AlgoHR |
| `25-college-and-university-portal.md` | College and university dashboards |
| `30-svar-spoken-english.md` | Mock SVAR |
| `31-mock-aptitude-daily-20.md` | Mock Aptitude |
| `32-debug-arena.md` | Mock Debug |
| `33-code-byte-and-coding.md` | Code Byte and coding practice |
| `40-ai-mock-interview.md` | AI Interview — booking and reports |
| `41-interview-agent-behaviour.md` | What the AI interviewer does |
| `42-proctoring-and-integrity.md` | Proctoring rules and consequences |
| `26-job-matches.md` | Job matches and recommendations |
| `99-escalation-and-limits.md` | Hand-off rules and unavailable features |
