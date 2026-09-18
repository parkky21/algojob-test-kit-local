---
product: AlgoHR — the recruiter portal
also_known_as: [AlgoHR, HR portal, company portal, employer, recruiter dashboard]
audience: [recruiter]
internal_service: algojob_nest (hr, recruitment, company, candidates, admin)
last_verified: 2026-09-18
---

# AlgoHR — the recruiter portal

## 1. What this is

AlgoHR is the employer side of AlgoJob. Recruiters post jobs, bring candidates in, configure an AI
interviewer for a role, run interview rounds and review the resulting evaluations — all from one
workspace.

## 2. Who can use it

Recruiters and hiring teams, with accounts created at `/company/signup` and signed in at
`/company/login`. Recruiter accounts are separate from candidate accounts and cannot be used to
practise.

Within a company, users can be given different roles and grouped into teams, so not every user sees
or can change everything.

## 3. Names and terms

| A user might say | Meaning |
|---|---|
| AlgoHR, the HR portal | this portal |
| JD | job description |
| agent, AI interviewer, bot | the configured AI interviewer for a role |
| panel | a group of interviewers |
| round | the interview stage: screening, technical, behavioural or HR |
| pipeline | your candidates and where each one is |

## 4. What you can do

### Jobs
- Create and manage **job postings**.
- Create **job description templates**, or upload a job description document and have its details
  read out of it.

### Candidates
- Add candidates individually, or **bulk upload** a list.
- Candidates you add who are not yet on AlgoJob are sent a **claim-profile** link so they can take
  ownership of their account.
- Track screening status across your pipeline.

### Company structure
- Manage your **company**, its **departments**, and **interview panels**.
- **User management** — invite colleagues, assign roles and put them in groups.

### The AI interviewer
- The **agent builder** configures the AI interviewer used for your roles: which round it runs,
  how long it runs for, and how strict the proctoring threshold is.
- Interviews run the same way candidates experience them — see `41-interview-agent-behaviour.md`.

### Results
- Review **evaluations** for interviews you scheduled: the overall score, the six-skill profile,
  strengths, gaps, and the recommendation.
- **Audit logs** record changes made in your workspace.
- **Alerts** surface things needing attention.

## 5. How an AI interview round works for you

1. Configure the interviewer for the role, or use an existing configuration.
2. Schedule the interview for a candidate.
3. The candidate receives their interview and joins from their browser.
4. The interviewer conducts the round and the evaluation is produced automatically.
5. You review the evaluation in the portal.

Interviews you schedule are proctored, and the evaluation records any proctoring alerts alongside
the score. See `42-proctoring-and-integrity.md`.

## 6. How the scoring works

Recruiter-facing evaluations use the same scoring described in `40-ai-mock-interview.md`,
section 6: an overall score out of 100 averaged from six skills, with a verdict derived from it —
**Strong Hire** at 80+, **Hire** at 60–79, **No Hire** below 60.

Read that file for the full breakdown; it applies identically here.

## 7. When things go wrong

### "A candidate's evaluation says 'Evaluation Pending' and scores 0"
That means the scoring failed on our side, not that the candidate performed badly. The transcript
was saved. **Contact support to have it re-scored.** Do not treat it as a real result or reject on
it.

### "A candidate has no evaluation at all"
If the candidate answered fewer than four questions, no evaluation is produced. The interview was
too short to score. Reschedule.

### "An evaluation is flagged for proctoring and scored 0"
The session reached the proctoring alert limit and was ended. The alert list is on the record. If
the candidate disputes it, contact support for a review rather than deciding from the score alone.

### "A candidate could not join"
The interview needs camera and microphone. The most common causes are a blocked permission or
another app holding the camera. Ask them to close Zoom, Meet and Teams and rejoin.

### "My bulk upload did not create accounts"
Uploaded candidates are sent claim-profile links. Until a candidate claims theirs, the account
exists but is unclaimed.

### "A colleague cannot see something I can"
Roles and groups control access. Check their role under user management.

## 8. Common questions

**Can I use one account for hiring and for practice?**
No. Recruiter and candidate accounts are separate.

**Can I change how long an interview runs?**
Yes, in the interviewer configuration for the role.

**Can I change how strict the proctoring is?**
The alert threshold is part of the interviewer configuration.

**Can I see the interview recording and transcript?**
Where recording was enabled, the recording and transcript are stored with the evaluation.

**Do candidates see their own evaluation?**
Candidates see reports for their own practice interviews. For interviews you scheduled, treat the
evaluation as yours.

**Can I re-run an evaluation on an existing transcript?**
Contact support — this is possible but not self-service.

**Can I export my candidate pipeline?**
Export options exist in the portal; where a specific export is not available, route to support.

## 9. What this does not do

- It does not let a recruiter account practise on the arenas.
- It does not let you see a candidate's private practice reports.
- It does not make hiring decisions for you — the verdict is a recommendation derived from the
  score.
- It does not guarantee a candidate's identity beyond what proctoring observes.

## 10. When to contact support

- Any evaluation reading "Evaluation Pending".
- A disputed proctoring termination.
- Re-running an evaluation.
- Bulk upload, role or permission problems.
- Invoicing and contract questions for your organisation.
