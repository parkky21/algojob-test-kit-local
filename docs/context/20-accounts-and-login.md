---
product: Accounts, signing in, profile and notifications
also_known_as: [login, sign in, sign up, register, OTP, password, account, profile, resume, notifications]
audience: [candidate, recruiter, college_admin, university_admin]
internal_service: algojob_nest (auth, candidates, notifications, email)
last_verified: 2026-09-18
---

# Accounts, signing in, profile and notifications

## 1. What this is

How you create an AlgoJob account, get into it, keep your profile current, and receive
notifications. Each type of user signs in at a different place.

## 2. Who this applies to

Everyone. **Sign-in pages are separate per role and they are not interchangeable.**

| You are a | Sign in at |
|---|---|
| Candidate / student | `/user/login` or `/student/login` |
| Recruiter (AlgoHR) | `/company/login` |
| College admin | `/college/login` |
| University admin | `/university-login` |

A candidate account cannot sign in to the recruiter portal, and vice versa. "Invalid credentials" on
the wrong portal is the single most common sign-in problem.

## 3. Names and terms

| A user might say | Meaning |
|---|---|
| OTP, code, verification code | the one-time code sent to your phone |
| social login, Google login | signing in with Google |
| claim my profile | taking ownership of an account a recruiter created for you |
| session expired, logged out | your sign-in has timed out |

## 4. How to sign up and sign in

### Candidates

**Three ways to sign in:**
1. **Phone number and OTP**, with a password set on your account.
2. **Email and password.**
3. **Sign in with Google.**

**To sign up:** go to `/user/signup`, choose email or phone, verify with the code sent to you, and
set a password. Signing up earns you **25 XP**, and completing your profile earns **100 XP**.

**Forgot your password:** use `/user/forgot-password`. You will be sent a code to verify, then you
can set a new one.

### Recruiters
Sign up at `/company/signup`, sign in at `/company/login`. Password reset is at
`/company/forgot-password`.

### College and university admins
Accounts are created for you by AlgoJob — there is no self-signup. You sign in with the credentials
you were given and set your own password at first sign-in.

## 5. Sessions

- You stay signed in for a while and are then asked to sign in again. Signing in on a new device
  does not sign you out of the old one.
- **Sign out from the account menu**, especially on a shared computer.
- If you are signed out mid-session unexpectedly, sign back in — your progress and reports are
  saved on your account, not in the browser.

## 6. Your profile

Your profile drives more than it looks like:

- **Your resume is read by the AI interviewer** to ask questions relevant to your experience. An
  empty or outdated resume produces a generic interview.
- Your **branch and subject** determine which Mock Debug curriculum you follow.
- Your **college** determines which college leaderboard you appear on.
- Completing your profile is a one-time **100 XP**.

Upload your resume as a PDF or Word document; the details are read out of it automatically and you
can correct anything it got wrong.

## 7. Claiming a profile

If a recruiter added you to their system before you had an account, you will get a link to
**claim your profile**. Following it lets you set a password and take ownership of the account,
keeping anything already on it. Claim links are single-use.

## 8. Notifications

- **In-app notifications** appear in the notifications area and arrive in real time — you do not
  need to refresh. They cover reports being ready, level-ups, and account events.
- **Email** is used for account and transactional messages.
- Notifications are kept for a period and then cleared automatically.

## 9. When things go wrong

### "Invalid credentials" when the password is definitely right
Check you are on the correct sign-in page for your role. A candidate account will not sign in at
`/company/login`.

### "I did not get my OTP"
Check the number is correct and has signal, and wait a moment before requesting another. If several
attempts produce nothing, sign in with email and password or with Google instead, and contact
support.

### "I signed up with Google but now cannot sign in with a password"
If you created your account with Google, keep using **Sign in with Google**. Use the forgot-password
flow to set a password if you want both.

### "I have two accounts"
Signing up with a phone number and separately with Google can create two separate accounts.
Contact support to have them merged — do not keep using both, or your XP and reports will be split.

### "I get signed out constantly"
Usually blocked cookies or private browsing. Allow cookies for the site and avoid private windows
for long sessions.

### "My resume details are wrong"
Details are read out of the file automatically and it does not always get everything right. Edit
them directly in your profile — the corrected version is what the AI interviewer uses.

### "My claim-profile link does not work"
Claim links are single-use and can expire. Ask the recruiter to resend it, or contact support.

### "I am on the wrong college leaderboard"
Correct your college in your profile. If your college is not listed, contact support.

### "I want to delete my account"
Contact support — this is not self-service.

## 10. Common questions

**Can I change my registered phone number or email?**
Update it in account settings. If you are locked out of both, contact support.

**Can I use one account on my laptop and my phone?**
Yes. Signing in on a second device does not sign you out of the first.

**Do I need to upload a resume?**
For AI interviews, effectively yes — the interviewer builds its questions from it. For the arenas,
no.

**Is my resume shown to recruiters?**
Recruiters you apply to or who scheduled an interview for you see your profile. Your practice
reports are yours.

**Can a recruiter account also practise?**
No. The portals are separate accounts with separate purposes.

**Why do I need to give my college?**
It places you on your college leaderboard and lets your college see aggregate progress.

**Can I change my password?**
Yes, in account settings, or through the forgot-password flow.

## 11. What this does not do

- There is no self-signup for college or university admin accounts.
- Accounts cannot be switched between roles.
- Accounts cannot be deleted from within the app.
- There is no offline or mobile-app sign-in — the platform is web only.

## 12. When to contact support

- Duplicate accounts that need merging.
- Account deletion.
- Locked out of both your registered phone and email.
- A college that does not appear in the list.
- A claim-profile link that will not work after the recruiter resends it.
