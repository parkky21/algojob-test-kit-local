---
product: College and university portals
also_known_as: [college dashboard, TPO, placement officer, university admin, rankings, at-risk students]
audience: [college_admin, university_admin]
internal_service: algojob_nest (college, university, analytics)
last_verified: 2026-09-18
---

# College and university portals

## 1. What this is

Institutions use AlgoJob to see how their students are actually progressing — who is practising,
who is improving, who is falling behind, and how the cohort compares. The **college portal** is for
a single institution; the **university portal** adds cross-institution analytics.

## 2. Who can use it

College and university administrators — placement officers, TPOs and equivalent staff. Accounts
are **created by AlgoJob**; there is no self-signup. Sign in at `/college/login` or
`/university-login` and set your own password at first sign-in.

## 3. Names and terms

| A user might say | Meaning |
|---|---|
| TPO, placement cell | the college admin role |
| roster, allowlist | the list of students permitted to join under your institution |
| at-risk | students flagged as falling behind |
| rankings | your internal student leaderboard |
| configuration | your institution's settings |

## 4. What you can do

### College portal
- **Dashboard** — activity and performance across your students.
- **Students** — manage your roster: who is allowed to register under your college, and their status.
- **Analytics** — performance by arena, by skill, over time.
- **Rankings** — your internal leaderboard.
- **Milestones** — cohort progress against targets.
- **Configuration** — your institution's settings.
- **Audit logs** — a record of changes made in your portal.
- **Exports** — bulk data export for your own reporting.

### University portal
- **Overview** across institutions.
- **Skills** breakdown for the cohort.
- **Attempt series** over time.
- **Top performers.**
- **At-risk students** — those whose activity or performance suggests they need help.
- **Per-student drill-down** into an individual's history.

## 5. How student data reaches you

Students practise under their own accounts. A student appears in your portal when their profile
records your college. If a student has the wrong college on their profile, they will not appear —
they fix this in their own profile.

Your view is of their **assessment activity and results**. Reports for individual attempts follow
the scoring described in each product's own file.

## 6. Rankings and leaderboards

Your college leaderboard ranks students on **XP earned in the current month**, so it resets
monthly and a student who starts late can still compete. Total XP and levels are separate and do
not reset. See `22-xp-levels-and-rewards.md`.

## 7. When things go wrong

### "A student is missing from my dashboard"
Their profile does not have your college recorded. They correct it in their own profile; it cannot
be changed from your side.

### "The numbers look lower than I expect"
Check the date range and remember that reports are only counted once scoring has finished. Attempts
still being scored have not landed.

### "A student's report shows 'Evaluation Pending' with a score of 0"
That is a scoring failure on our side, not the student's performance. Contact support to have it
re-scored, and do not include it in cohort statistics.

### "A student was flagged for proctoring and disputes it"
Contact support and ask for the session to be reviewed, with the date and time. Do not resolve it
from the score alone. See `42-proctoring-and-integrity.md`.

### "Rankings changed unexpectedly at the start of the month"
The leaderboard is monthly and resets. Levels and total XP do not.

### "I need data that is not in an export"
Contact support with what you need.

## 8. Common questions

**How do students get added?**
They sign up themselves and record your college on their profile. Your roster controls who is
permitted.

**Can I see a student's individual reports?**
The university portal has a per-student drill-down. Scope depends on your institution's
configuration.

**Can I create admin accounts for colleagues?**
College admin accounts are provisioned by AlgoJob. Contact support.

**Can I set my own assessment limits or rules for my students?**
Institution-level configuration exists. Contact support for what can be changed for your college.

**Do my students need to pay?**
No. All the arenas work on the free plan. PRO raises individual limits — see
`21-plans-credits-and-billing.md`.

**Can I export everything?**
Bulk exports are available in the college portal. For anything beyond them, contact support.

## 9. What this does not do

- It does not let you change a student's profile, including their college.
- It does not let you take assessments on a student's behalf.
- It does not create student accounts for them.
- It does not expose a student's billing details.

## 10. When to contact support

- Provisioning admin accounts for colleagues.
- Institution-level configuration changes.
- Any report reading "Evaluation Pending".
- Disputed proctoring terminations.
- Data or exports not available in the portal.
- Contract, invoicing and licensing questions.
